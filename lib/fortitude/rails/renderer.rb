::ActiveSupport::SafeBuffer.class_eval do
  alias_method :fortitude_concat, :original_concat
  public :fortitude_concat
end

module Fortitude
  module Rails
    class Renderer
      class << self
        def render(widget_class, template_handler, local_assigns, is_partial)
          widget = widget_class.new(template_handler.assigns.merge(local_assigns).with_indifferent_access)
          template_handler.with_output_buffer do
            out = ""
            widget.to_html(out)
            template_handler.output_buffer << out.html_safe
          end
        end
      end
    end
  end
end
