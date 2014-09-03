require 'fortitude/rails/renderer'

module Fortitude
  module Rails
    class TemplateHandler
      def call(template, &block)
        require_dependency template.identifier
        widget_class_name = "views/#{template.identifier =~ %r(views/([^.]*)(\..*)?\.rb) && $1}".camelize
        is_partial = !! (File.basename(template.identifier) =~ /^_/)

        <<-SRC
        Fortitude::Rails::Renderer.render(#{widget_class_name}, self, local_assigns, #{is_partial.inspect}) { |*args| yield *args }
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
