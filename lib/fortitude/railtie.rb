if defined?(ActiveSupport)
  ActiveSupport.on_load(:before_initialize) do
    ActiveSupport.on_load(:action_view) do
      require "fortitude/rails/template_handler"
    end
  end
end

module Fortitude
  class Railtie < ::Rails::Railtie
    initializer :fortitude, :before => :set_autoload_paths do |app|
      # All of this code is involved in setting up autoload_paths to work with Fortitude.
      # Why so hard?
      #
      # We're trying to do something that ActiveSupport::Dependencies -- which is what Rails uses for
      # class autoloading -- doesn't really support. We want app/views to be on the autoload path,
      # because there are now Ruby classes living there. (It usually isn't just because all that's there
      # are template source files, not actual Ruby code.) That isn't an issue, though -- adding it
      # is trivial (just <tt>ActiveSupport::Dependencies << File.join(Rails.root, 'app/views')</tt>).
      #
      # The real issue is that we want the class <tt>app/views/foo/bar.rb</tt> to define a class called
      # <tt>Views::Foo::Bar</tt>, not just plain <tt>Foo::Bar</tt>. This is what's different from what
      # ActiveSupport::Dependencies normally supports; it expects the filesystem path underneath the
      # root to be exactly identical to the fully-qualified class name.
      #
      # Why are we doing this crazy thing? Because we want you to be able to have a view called
      # <tt>app/views/user/password.rb</tt>, and _not_ have that conflict with a module you just happen to define
      # elsewhere called <tt>User::Password</tt>. If we don't prefix view classes with anything at all, then the
      # potential for conflicts is enormous.
      #
      # As such, we have this code. We'll walk through it step-by-step; note that at the end we *do*
      # add app/views/ to the autoload path, so all this code is doing is just dealing with the fact that
      # the fully-qualified classname (<tt>Views::Foo::Bar</tt>) has one extra component on the front of it
      # (<tt>Views::</tt>) when compared to the subpath (<tt>foo/bar.rb</tt>) underneath what's on the autoload
      # path (<tt>app/views</tt>).

      # Go compute our views root.
      views_root = File.expand_path(File.join(::Rails.root, 'app', 'views'))

      # Now, do all this work inside ::ActiveSupport::Dependencies...
      ::ActiveSupport::Dependencies.module_eval do
        @@_fortitude_views_root = views_root

        # Overrides #loadable_constants_for_path, which is described as follows:
        #
        # "Given +path+, a filesystem path to a ruby file, return an array of
        # constant paths which would cause Dependencies to attempt to load this
        # file."
        #
        # So this means that if we get a full path to <tt>.../app/views/foo/bar.rb</tt>,
        # we need to return <tt>Views::Foo::Bar</tt>, while the original code would return
        # just <tt>Foo::Bar</tt>. On the other hand, if we get a path that is anywhere
        # outside <tt>.../app/views</tt>, then we just call the original method.
        def loadable_constants_for_path_with_fortitude(path, bases = autoload_paths)
          path = $` if path =~ /\.rb\z/
          expanded_path = File.expand_path(path)

          raise "kaboomba"

          # Are we under the views root?
          if %r{\A#{Regexp.escape(@@_fortitude_views_root)}(/|\\)} =~ expanded_path
            # Yup -- so add "views" on the front.
            nesting = "views" + expanded_path[(@@_fortitude_views_root.size)..-1]
            [ nesting.camelize ]
          else
            loadable_constants_for_path_without_fortitude(path, bases)
          end
        end

        # alias_method_chain :loadable_constants_for_path, :fortitude

        # This is the method that gets called to auto-generate namespacing empty
        # modules (_e.g._, the toplevel <tt>Views::</tt> module) for directories
        # under an autoload path.
        #
        # The original method says:
        #
        # Does the provided path_suffix correspond to an autoloadable module?
        # Instead of returning a boolean, the autoload base for this module is
        # returned.
        #
        # So, we just need to strip off the leading +views/+ from the +path_suffix+,
        # and see if that maps to a directory underneath <tt>app/views/</tt>; if so,
        # we'll return the path to <tt>.../app/views/</tt>. Otherwise, we just
        # delegate back to the superclass method.
        def autoloadable_module_with_fortitude?(path_suffix)
          if path_suffix =~ %r{^views(/.*)?$}i
            # If we got here, then we were passed a subpath of views/....
            subpath = $1

            if subpath.blank? || File.directory?(File.join(@@_fortitude_views_root, subpath))
              return @@_fortitude_views_root
            end
          end

          with_fortitude_views_removed_from_autoload_path do
            autoloadable_module_without_fortitude?(path_suffix)
          end
        end

        # When we delegate back to original methods, we want them to act as if
        # <tt>app/views/</tt> is _not_ on the autoload path. In order to be thread-safe
        # about that, we couple this method with our override of the writer side of the
        # <tt>mattr_accessor :autoload_paths</tt>, which simply prefers the thread-local
        # that we set to the actual underlying variable.
        def with_fortitude_views_removed_from_autoload_path
          begin
            Thread.current[:_fortitude_autoload_paths_override] = autoload_paths - [ @@_fortitude_views_root ]
            yield
          ensure
            Thread.current[:_fortitude_autoload_paths_override] = nil
          end
        end

        alias_method_chain :autoloadable_module?, :fortitude

        def search_for_file_with_fortitude(path_suffix)
          new_path_suffix = path_suffix.sub(/(\.rb)?$/, ".rb")

          if new_path_suffix =~ %r{^views(/.*)$}i
            path = File.join(@@_fortitude_views_root, $1)
            if File.file?(path)
              return path
            end
          end

          out = search_for_file_without_fortitude(path_suffix)
          if out
            if out[0..(@@_fortitude_views_root.length)] == "#{@@_fortitude_views_root}/"
              # We were looking for Foo::Bar, but found it as app/views/foo/bar.rb (because it's app/views on the
              # autoload path, not just app/); we don't want to allow this. In order to avoid it, we have to do a
              # seriously ugly workaround: we need to
              with_fortitude_views_removed_from_autoload_path { out = search_for_file_without_fortitude(path_suffix) }
            end
          end
          out
        end

        alias_method_chain :search_for_file, :fortitude
      end

      # It turns out that if we use the block form of class_eval here, @@autoload_paths ends up referring
      # to the *Railtie*, not to ::ActiveSupport::Dependencies. So...we use the string form.
      ::ActiveSupport::Dependencies.class_eval <<-EOS
  def self.autoload_paths
    Thread.current[:_fortitude_autoload_paths_override] || @@autoload_paths
  end
EOS

      ::ActiveSupport::Dependencies.autoload_paths << views_root

      ::ActionView::PathResolver.class_eval do
        def find_templates_with_fortitude(name, prefix, partial, details)
          templates = find_templates_without_fortitude(name, prefix, partial, details)
          if partial && templates.empty? && details[:handlers] && details[:handlers].include?(:rb)
            templates = find_templates_without_fortitude(name, prefix, false, details.merge(:handlers => [ :rb ]))
          end
          templates
        end

        alias_method_chain :find_templates, :fortitude
      end


      require "fortitude/rails/template_handler"
    end
  end
end
