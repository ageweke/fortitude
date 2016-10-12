require 'fortitude/rails/renderer'

module Fortitude
  module Rails
    class TemplateHandler
      def call(template, &block)
        <<-SRC
        Fortitude::Rails::Renderer.render_file(#{template.identifier.to_s.inspect}, view_paths, self, local_assigns) { |*args| yield *args }
        SRC
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
