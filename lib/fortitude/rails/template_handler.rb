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

        pathname = "#{template.identifier =~ %r(views/(.*)) && $1}"

        <<-SRC
        Fortitude::Rails::Renderer.render(#{widget_class.name}, self, local_assigns, #{is_partial.inspect}, pathname: "#{pathname}") { |*args| yield *args }
        SRC
      end

      def supports_streaming?
        true
      end
    end
  end
end

::ActionView::Template.class_eval do
  class << self
    def _fortitude_register_template_handler!
      register_template_handler_without_fortitude(:rb, Fortitude::Rails::TemplateHandler.new)
    end

    def register_template_handler_with_fortitude(*args, &block)
      register_template_handler_without_fortitude(*args, &block)
      ActionView::Template._fortitude_register_template_handler!
    end

    alias_method_chain :register_template_handler, :fortitude
  end
end

ActionView::Template._fortitude_register_template_handler!
