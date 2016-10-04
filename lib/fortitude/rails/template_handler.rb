require 'fortitude/rails/renderer'

module Fortitude
  module Rails
    class TemplateHandler
      def call(template, &block)
        view_paths = ::Rails.application.paths['app/views'].map do |path|
          File.expand_path(path.to_s, ::Rails.root.to_s)
        end
        valid_base_classes = [ ::Fortitude::Widget, ::Fortitude::Erector.erector_widget_base_class_if_available ].compact

        widget_class = ::Fortitude::Widget.widget_class_from_file(template.identifier.to_s,
          :root_dirs => view_paths, :valid_base_classes => valid_base_classes)

        is_partial = !! File.basename(template.identifier) =~ /^_/

        <<-SRC
        Fortitude::Rails::Renderer.render(#{widget_class.name}, self, local_assigns, #{is_partial.inspect}) { |*args| yield *args }
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
