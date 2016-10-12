require 'fortitude/rails/renderer'

module Fortitude
  module Rails
    class TemplateHandler
      def call(template, &block)
        # This is a little funny. Under almost every single circumstance, we can, at template-compile time, deduce
        # what class is inside the template file, and simply call Fortitude::Rails::Renderer.render with that class.
        #
        # However, there is one case under which we can't: if you've added to the view paths in the controller
        # (using something like +append_view_path+), the template you're rendering is in an added view path,
        # *and* that template has an "un-guessable" class name -- meaning you're doing something seriously strange
        # in its source code. (See the view_paths_system_spec's test case with an "impossible-to-guess name" for the
        # exact circumstances.) Under that case, the only way everything can work completely correctly is if we
        # delay trying to figure out the class name from the template filename until rendering time, when we'll have
        # the view paths available.
        #
        # This second path, however, is slower, because it has to do I/O to figure out that class name. (This adds
        # about 1ms on my 2013 MacBook Pro with SSD.) So, we try the fast path first, and only fall back to the slow
        # path if absolutely necessary.
        expanded_view_paths = ::Rails.application.paths['app/views'].map { |path| File.expand_path(path.to_s, ::Rails.root.to_s) }
        valid_base_classes = [ ::Fortitude::Widget, ::Fortitude::Erector.erector_widget_base_class_if_available ].compact
        is_partial = !! File.basename(template.identifier) =~ /^_/

        widget_class = nil

        begin
          widget_class = ::Fortitude::Widget.widget_class_from_file(template.identifier.to_s,
            :root_dirs => expanded_view_paths, :valid_base_classes => valid_base_classes)

          <<-SRC
          Fortitude::Rails::Renderer.render(#{widget_class.name}, self, local_assigns, #{is_partial.inspect}) { |*args| yield *args }
          SRC
        rescue Fortitude::Widget::Files::CannotDetermineWidgetClassNameError => cdwcne
          <<-SRC
          Fortitude::Rails::Renderer.render_file(#{template.identifier.to_s.inspect}, view_paths, self, local_assigns) { |*args| yield *args }
          SRC
        end
      end

      def supports_streaming?
        true
      end

      class << self
        def register!
          ::ActionView::Template.register_template_handler(:rb, ::Fortitude::Rails::TemplateHandler.new)
        end
      end
    end

    module RegisterTemplateHandlerOverrides
      def register_template_handler_uniwith_fortitude(original_method, *args, &block)
        original_method.call(*args, &block)

        unless args[0] == :rb && args[1].instance_of?(::Fortitude::Rails::TemplateHandler)
          original_method.call(:rb, ::Fortitude::Rails::TemplateHandler.new)
        end
      end
    end
  end
end

eigenclass = ::ActionView::Template.class_eval "class << self; self; end"
::Fortitude::MethodOverriding.override_methods(
  eigenclass, ::Fortitude::Rails::RegisterTemplateHandlerOverrides, :fortitude, [ :register_template_handler ])

::Fortitude::Rails::TemplateHandler.register!
