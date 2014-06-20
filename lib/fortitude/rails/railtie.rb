require 'fortitude/rendering_context'

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
      config.after_initialize do
        if Fortitude.refine_rails_helpers
          require 'fortitude/rails/helpers'
          Fortitude::Rails::Helpers.apply_refined_helpers_to!(Fortitude::Widget)
        end

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
        # class autoloading -- doesn't really support. We want app/views to be on the autoload path,
        # because there are now Ruby classes living there. (It usually isn't just because all that's there
        # are template source files, not actual Ruby code.) That isn't an issue, though -- adding it
        # is trivial (just do
        # <tt>ActiveSupport::Dependencies.autoload_paths << File.join(Rails.root, 'app/views')</tt>).
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

          alias_method_chain :autoloadable_module?, :fortitude

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

          # The use of 'class_eval' here may seem funny, and I think it is, but, without it,
          # the +@@autoload_paths+ gets interpreted as a class variable for this *Railtie*,
          # rather than for ::ActiveSupport::Dependencies. (Why is that? Got me...)
          class_eval <<-EOS
            def self.autoload_paths
              Thread.current[:_fortitude_autoload_paths_override] || @@autoload_paths
            end
          EOS

          # The original method says:
          #
          # "Search for a file in autoload_paths matching the provided suffix."
          #
          # So, we just look to see if the given +path_suffix+ is specifying something like
          # <tt>views/foo/bar</tt>; if so, we glue it together properly, removing the initial
          # <tt>views/</tt> first. (Otherwise, the mechanism would expect
          # <tt>Views::Foo::Bar</tt> to show up in <tt>app/views/views/foo/bar</tt> (yes, a double
          # +views+), since <tt>app/views</tt> is on the autoload path.)
          def search_for_file_with_fortitude(path_suffix)
            # This just makes sure our path always ends in exactly one ".rb", whether it started
            # with one or not.
            new_path_suffix = path_suffix.sub(/(\.rb)?$/, ".rb")

            if new_path_suffix =~ %r{^views(/.*)$}i
              path = File.join(@@_fortitude_views_root, $1)
              return path if File.file?(path)
            end

            # Make sure that we remove the views autoload path before letting the rest of
            # the dependency mechanism go searching for files, or else <tt>app/views/foo/bar.rb</tt>
            # *will* be found when looking for just <tt>::Foo::Bar</tt>.
            with_fortitude_views_removed_from_autoload_path { search_for_file_without_fortitude(path_suffix) }
          end

          alias_method_chain :search_for_file, :fortitude
        end

        # And, finally, this is where we add our root to the set of autoload paths.
        ::ActiveSupport::Dependencies.autoload_paths << views_root

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

        # This is our support for render :widget. Although, originally, it looked like creating a new subclass
        # of ActionView::Template was going to be the correct thing to do here, it turns out it isn't: the entire
        # template system is predicated around the idea that you have a template, which is compiled to output
        # Ruby source code, and then that gets evaluated to actually generate output.
        #
        # Because <tt>render :widget => ...</tt> takes an already-instantiated widget as input, this simply isn't
        # possible: you can't reverse-engineer an arbitrary Ruby object into source code, and, without source code,
        # the whole templating paradigm doesn't make sense.
        #
        # So, instead, we simply transform <tt>render :widget => ...</tt> into a <tt>render :text => ...</tt> of the
        # widget's output, and let Rails take it away from there.
        ::ActionController::Base.class_eval do
          def fortitude_rendering_context(options)
            @_fortitude_rendering_context ||= create_fortitude_rendering_context(options)
          end

          def create_fortitude_rendering_context(options)
            ::Fortitude::RenderingContext.new(options)
          end

          def render_with_fortitude(*args, &block)
            if (options = args[0]).kind_of?(Hash)
              if (widget = options[:widget])
                rendering_context = fortitude_rendering_context(:delegate_object => self)
                widget.to_html(rendering_context)

                options = options.dup
                options[:text] = rendering_context.output_buffer_holder.output_buffer.html_safe
                options[:layout] = true unless options.has_key?(:layout)

                new_args = [ options ] + args[1..-1]
                return render_without_fortitude(*new_args, &block)
              elsif (widget_block = options[:inline]) && (options[:type] == :fortitude)
                options.delete(:inline)

                rendering_context = fortitude_rendering_context(:delegate_object => self)
                widget_class = Class.new(Fortitude::Widgets::Html5)
                widget_class.use_instance_variables_for_assigns(true)
                widget_class.extra_assigns(:use)
                widget_class.send(:define_method, :content, &widget_block)

                assigns = { }
                instance_variables.each do |ivar_name|
                  value = instance_variable_get(ivar_name)
                  assigns[$1.to_sym] = value if ivar_name =~ /^@(.*)$/
                end
                assigns = assigns.merge(options[:locals] || { })

                widget = widget_class.new(assigns)
                widget.to_html(rendering_context)

                options = options.dup
                options[:text] = rendering_context.output_buffer_holder.output_buffer.html_safe
                options[:layout] = true unless options.has_key?(:layout)

                new_args = [ options ] + args[1..-1]
                return render_without_fortitude(*new_args, &block)
              end
            end

            return render_without_fortitude(*args, &block)
          end

          alias_method_chain :render, :fortitude
        end
      end
    end
  end
end
