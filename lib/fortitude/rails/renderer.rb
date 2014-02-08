require 'fortitude/rendering_context'

::ActiveSupport::SafeBuffer.class_eval do
  alias_method :fortitude_concat, :original_concat
  public :fortitude_concat
end

module Fortitude
  module Rails
    class Renderer
      class << self
        # TODO: Refactor this and render :widget => ... support into one method somewhere.
        def render(widget_class, template_handler, local_assigns, &block)
          widget = widget_class.new(template_handler.assigns.merge(local_assigns).with_indifferent_access)
          template_handler.with_output_buffer do
            rendering_context = ::Fortitude::RenderingContext.new(template_handler, template_handler, template_handler.output_buffer, block)
            widget.to_html(rendering_context)
            rendering_context.flush!
          end
        end
      end
    end
  end
end
