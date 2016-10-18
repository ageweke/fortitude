require 'fortitude/rendering_context'
require 'fortitude/rails/fortitude_rails_helpers'
require 'fortitude/support/method_overriding'
require 'thread'

if defined?(ActiveSupport)
  ActiveSupport.on_load(:before_initialize) do
    ActiveSupport.on_load(:action_view) do
      require "fortitude/rails/template_handler"
    end
  end
end

module Fortitude
  class << self
    def refine_rails_helpers(on_or_off = :not_specified)
      @refine_rails_helpers = !! on_or_off unless on_or_off == :not_specified
      !! @refine_rails_helpers
    end
  end

  refine_rails_helpers true
end

module Fortitude
  module Rails
    class Railtie < ::Rails::Railtie
      config.app_generators.template_engine :fortitude

      class << self
        def _fortitude_view_roots
          @_fortitude_view_roots_mutex.synchronize do
            raise "@_fortitude_view_roots has not yet been set" unless @_fortitude_view_roots
            @_fortitude_view_roots
          end
        end

        def _fortitude_view_roots=(x)
          @_fortitude_view_roots_mutex.synchronize do
            if @_fortitude_view_roots_locked
              raise "@_fortitude_view_roots was locked, and cannot be changed. It was locked at:\n  #{@_fortitude_view_roots_locked}"
            end

            @_fortitude_view_roots = x
          end
        end

        def _lock_fortitude_view_roots!
          @_fortitude_view_roots_mutex.synchronize do
            @_fortitude_view_roots_locked ||= caller.join("\n")
          end
        end
      end

      @_fortitude_view_roots_mutex = Mutex.new

      config.after_initialize do
        if Fortitude.refine_rails_helpers
          require 'fortitude/rails/helpers'
          Fortitude::Rails::Helpers.apply_refined_helpers_to!(Fortitude::Widget)
        end

        ::ActionView::Base.send(:include, ::Fortitude::Rails::FortitudeRailsHelpers)

        if ::Rails.env.development?
          ::Fortitude::Widget.class_eval do
            format_output true
            start_and_end_comments true
            debug true
          end
        end
      end

      initializer :fortitude, :before => :set_autoload_paths do |app|
        # All of this code is involved in setting up autoload_paths to work with Fortitude.
        # Why so hard?
        #
        # We're trying to do something that ActiveSupport::Dependencies -- which is what Rails uses for
        # class autoloading -- doesn't really support. We want all view paths to be on the autoload path,
        # because there are now Ruby classes living there. (It usually isn't just because all that's there
        # are template source files, not actual Ruby code.) That isn't an issue, though -- adding it
        # is trivial (just do
        # <tt>ActiveSupport::Dependencies.autoload_paths += ::Rails.application.paths['app/views'].expanded</tt>).
        #
        # The real issue is that we want the class (<em>e.g.</em>) <tt>app/views/foo/bar.rb</tt> to define a class
        # called <tt>Views::Foo::Bar</tt>, not just plain <tt>Foo::Bar</tt>. This is what's different from what
        # ActiveSupport::Dependencies normally supports; it expects the filesystem path underneath the
        # root to be exactly identical to the fully-qualified class name.
        #
        # Why are we doing this crazy thing? Because we want you to be able to have a view called
        # <tt>app/views/user/password.rb</tt>, and _not_ have that conflict with a module you just happen to define
        # elsewhere called <tt>User::Password</tt>. If we don't prefix view classes with anything at all, then the
        # potential for conflicts is enormous.
        #
        # As such, we have this code. We'll walk through it step-by-step; note that at the end we *do*
        # add all view paths to the autoload path, so all this code is doing is just dealing with the fact that
        # the fully-qualified classname (<tt>Views::Foo::Bar</tt>) has one extra component on the front of it
        # (<tt>Views::</tt>) when compared to the subpath (<tt>foo/bar.rb</tt>) underneath what's on the autoload
        # path (<tt>app/views</tt>).

        # Go compute our view roots.
        #
        # Rails 3.0.x doesn't define #expanded on ::Rails::Paths::Path; it also has a different way of getting at
        # the view paths (<tt>::Rails.application.paths.app.views</tt>, rather than
        # <tt>::Rails.application.paths['app/views']</tt>). So, if we're on Rails 3.0.x, we simply inline the
        # equivalent code here.
        view_roots = if ::Rails.version =~ /^3\.0\./
          paths = ::Rails.application.paths.app.views

          result = []

          paths.each do |p|
            root_path = p.instance_variable_get("@root")
            root = if root_path then root_path.path else ::Rails.root end
            glob = p.instance_variable_get("@glob")

            path = File.expand_path(p, root)

            if glob && File.directory?(path)
              Dir.chdir(path) do
                result.concat(Dir.glob(glob).map { |file| File.join path, file }.sort)
              end
            else
              result << path
            end
          end

          result.uniq!
          result
        else
          ::Rails.application.paths['app/views'].expanded
        end

        ::Fortitude::Rails::Railtie._fortitude_view_roots = view_roots

        module ActiveSupportDependenciesOverrides
          class << self
            # When we delegate back to original methods, we want them to act as if
            # all view roots are _not_ on the autoload path. In order to be thread-safe
            # about that, we couple this method with our override of the writer side of the
            # <tt>mattr_accessor :autoload_paths</tt>, which simply prefers the thread-local
            # that we set to the actual underlying variable.
            def with_fortitude_views_removed_from_autoload_path
              begin
                Thread.current[:_fortitude_autoload_paths_override] =
                  ::ActiveSupport::Dependencies.autoload_paths -
                  ::Fortitude::Rails::Railtie._fortitude_view_roots

                yield
              ensure
                Thread.current[:_fortitude_autoload_paths_override] = nil
              end
            end
          end

          module Common
            def autoload_paths_uniwith_fortitude(original_method)
              Thread.current[:_fortitude_autoload_paths_override] || original_method.call
            end

            # This is the method that gets called to auto-generate namespacing empty
            # modules (_e.g._, the toplevel <tt>Views::</tt> module) for directories
            # under an autoload path.
            #
            # The original method says:
            #
            # "Does the provided path_suffix correspond to an autoloadable module?
            # Instead of returning a boolean, the autoload base for this module is
            # returned."
            #
            # So, we just need to strip off the leading +views/+ from the +path_suffix+,
            # and see if that maps to a directory underneath one of our view roots; if so,
            # we'll return the path to that view root. Otherwise, we just
            # delegate back to the superclass method.
            def autoloadable_module_uniwith_fortitude?(original_method, path_suffix)
              if path_suffix =~ %r{^(views)(/.*)?$}i
                # If we got here, then we were passed a subpath of views/....
                prefix = $1
                subpath = $2

                if subpath.blank?
                  ::Fortitude::Rails::Railtie._fortitude_view_roots.each do |view_root|
                    return view_root if File.basename(view_root).strip.downcase == prefix.strip.downcase
                  end
                else
                  ::Fortitude::Rails::Railtie._fortitude_view_roots.each do |view_root|
                    return view_root if File.directory?(File.join(view_root, subpath))
                  end
                end
              end

              ActiveSupportDependenciesOverrides.with_fortitude_views_removed_from_autoload_path do
                original_method.call(path_suffix)
              end
            end

            # The original method says:
            #
            # "Search for a file in autoload_paths matching the provided suffix."
            #
            # So, we just look to see if the given +path_suffix+ is specifying something like
            # <tt>views/foo/bar</tt> or the fully-qualified version thereof; if so, we glue it together properly,
            # removing the initial <tt>views/</tt> first. (Otherwise, the mechanism would expect
            # <tt>Views::Foo::Bar</tt> to show up in <tt>app/views/views/foo/bar</tt> (yes, a double
            # +views+), since <tt>app/views</tt> is on the autoload path.)
            def search_for_file_uniwith_fortitude(original_method, path_suffix)
              # Remove any ".rb" extension, if present...
              new_path_suffix = path_suffix.sub(/(\.rb)?$/, "")

              found_subpath = nil
              if new_path_suffix =~ %r{^views(/.*)$}i
                found_subpath = $1
              else
                ::Fortitude::Rails::Railtie._fortitude_view_roots.each do |view_root|
                  if new_path_suffix =~ %r{^#{Regexp.escape(view_root)}(/.*)$}i
                    found_subpath = $1
                    break
                  end
                end
              end

              if found_subpath
                ::Fortitude::Rails::Railtie._fortitude_view_roots.each do |view_root|
                  full_path = File.join(view_root, "#{found_subpath}")
                  directory = File.dirname(full_path)

                  if File.directory?(directory)
                    filename = File.basename(full_path)

                    regexp1 = /^_?#{Regexp.escape(filename)}\./
                    regexp2 = /\.rb$/i
                    applicable_entries = Dir.entries(directory).select do |entry|
                      ((entry == filename) || (entry =~ regexp1 && entry =~ regexp2)) && File.file?(File.join(directory, entry))
                    end

                    return nil if applicable_entries.length == 0

                    # Prefer those without an underscore
                    without_underscore = applicable_entries.select { |e| e !~ /^_/ }
                    applicable_entries = without_underscore if without_underscore.length > 0

                    entry_to_use = applicable_entries.sort_by { |e| e.length }.reverse.first
                    return File.join(directory, entry_to_use)
                  end
                end
              end

              # Make sure that we remove the views autoload path before letting the rest of
              # the dependency mechanism go searching for files, or else <tt>app/views/foo/bar.rb</tt>
              # *will* be found when looking for just <tt>::Foo::Bar</tt>.
              ActiveSupportDependenciesOverrides.with_fortitude_views_removed_from_autoload_path do
                original_method.call(path_suffix)
              end
            end
          end
        end

        ::Fortitude::MethodOverriding.override_methods(
          ::ActiveSupport::Dependencies, ActiveSupportDependenciesOverrides::Common, :fortitude,
          [ :search_for_file, :autoloadable_module?, :autoload_paths ])

        eigenclass = ::ActiveSupport::Dependencies.module_eval "class << self; self; end"
        ::Fortitude::MethodOverriding.override_methods(
          eigenclass, ActiveSupportDependenciesOverrides::Common, :fortitude,
          [ :autoload_paths ])

        module RailsEngineOverrides
          # Two important comments here:
          #
          # 1: We also need to patch ::Rails::Engine.eager_load! so that it loads classes under all view roots. However, we
          # can't just add them to the normal eager load paths, because that will allow people to do "require 'foo/bar'"
          # and have it match app/views/foo/bar.rb, which we don't want. So, instead, we load these classes ourselves.
          # Note that we ALSO have to do things slightly differently than Rails does it, because we need to skip loading
          # 'foo.rb' if 'foo.html.rb' exists -- and because we have to require the fully-qualified pathname, since
          # app/views is not actually on the load path.
          #
          # 2: I (ageweke) added this very late in the path of Fortitude development, after trying to use Fortitude in a
          # deployment (production) environment in which widgets just weren't getting loaded at all. Yet there's something
          # I don't understand: clearly, without this code, widgets will not be eager-loaded (which is probably not a
          # great thing for performance reasons)...but I think they still should get auto-loaded and hence actually work
          # just fine. But they don't in that environment (you'll get errors like "uninitialized constant Views::Base").
          # Since I understand what's going on and have the fix for it here, that's fine...except that I can't seem to
          # write a spec for it, because I don't know how to actually *make* it fail. If anybody comes along later and
          # knows what would make it fail (and I double-checked, and we don't have autoloading disabled in production or
          # anything like that), let me know, so that I can write a spec for this. Thanks!
          def eager_load_uniwith_fortitude!(original_method)
            original_method.call
            eager_load_fortitude_views!
          end

          def eager_load_fortitude_views!
            ::Fortitude::Rails::Railtie._fortitude_view_roots.each do |load_path|
              all_files = Dir.glob("#{load_path}/**/*.rb")
              matcher = /\A#{Regexp.escape(load_path.to_s)}\/(.*)\.rb\Z/

              all_files.sort.each do |full_path|
                filename = File.basename(full_path, ".rb")
                directory = File.dirname(full_path)

                longer_name_regex = /^#{Regexp.escape(filename)}\..+\.rb$/i
                longer_name = Dir.entries(directory).detect { |e| e =~ longer_name_regex }

                unless longer_name
                  require_dependency File.join('views', full_path.sub(matcher, '\1'))
                end
              end
            end
          end
        end

        ::Fortitude::MethodOverriding.override_methods(
          ::Rails::Engine, RailsEngineOverrides, :fortitude, [ :eager_load! ])

        # And, finally, this is where we add our view roots to the set of autoload paths.
        ::ActiveSupport::Dependencies.autoload_paths += view_roots

        module ActionViewPathResolverOverrides
          # This is our support for partials. Fortitude doesn't really have a distinction between
          # partials and "full" templates -- everything is just a widget, which is much more elegant --
          # but we still want you to be able to render a widget <tt>Views::Foo::Bar</tt> by saying
          # <tt>render :partial => 'foo/bar'</tt> (from ERb, although you can do it from Fortitude if
          # you want for some reason, too).
          #
          # Normally, ActionView only looks for partials in files starting with an underscore. We
          # do want to allow this, too (in the above case, if you define the widget in the file
          # <tt>app/views/foo/_bar.rb</tt>, it will still work fine); however, we also want to allow
          # you to define it in a file that does _not_ start with an underscore ('cause these are
          # Ruby classes, and that's just plain weird).
          #
          # So, we patch #find_templates: if it's looking for a partial, doesn't find one, and is
          # searching Fortitude templates (the +.rb+ handler), then we try again, turning off the
          # +partial+ flag, and return that instead.
          def find_templates_uniwith_fortitude(original_method, name, prefix, partial, details, *args)
            templates = original_method.call(name, prefix, partial, details, *args)
            if partial && templates.empty? && details[:handlers] && details[:handlers].include?(:rb)
              templates = original_method.call(name, prefix, false, details.merge(:handlers => [ :rb ]), *args)
            end
            templates
          end
        end

        ::Fortitude::MethodOverriding.override_methods(
          ::ActionView::PathResolver, ActionViewPathResolverOverrides, :fortitude, [ :find_templates ])

        require "fortitude/rails/template_handler"
        require "fortitude/rails/rendering_methods"

        ::Fortitude::Rails::RenderingMethods.include_into!(::ActionController::Base)
        ::Fortitude::Rails::RenderingMethods.include_into!(::ActionMailer::Base)
      end
    end
  end
end
