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

      module RegisterTemplateHandlerWithFortitude
        def self.prepended(base)
          class << base
            alias_method :orig_register_template_handler,
                         :register_template_handler
            prepend ClassMethods
          end
        end

        module ClassMethods
          def register_template_handler(*args, &block)
            super(*args, &block)

            ActionView::Template._fortitude_register_template_handler!
          end

          def _fortitude_register_template_handler!
            orig_register_template_handler(
              :rb,
              Fortitude::Rails::TemplateHandler.new
            )
          end
        end
      end
    end
  end
end

::ActionView::Template.prepend(
  Fortitude::Rails::TemplateHandler::RegisterTemplateHandlerWithFortitude
)

ActionView::Template._fortitude_register_template_handler!
