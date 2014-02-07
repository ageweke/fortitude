require 'fortitude/rails/renderer'

module Fortitude
  module Rails
    class TemplateHandler
      def call(template, &block)
        require_dependency template.identifier
        widget_class_name = "views/#{template.identifier =~ %r(views/([^.]*)(\..*)?\.rb) && $1}".camelize
        is_partial = File.basename(template.identifier) =~ /^_/

        <<-SRC
        Fortitude::Rails::Renderer.render(#{widget_class_name}, self, local_assigns) { |*args| yield *args }
        SRC
      end
    end
  end
end

ActionView::Template.register_template_handler :rb, Fortitude::Rails::TemplateHandler.new
