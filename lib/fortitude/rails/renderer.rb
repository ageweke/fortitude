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
          total_assigns = template_handler.assigns.merge(local_assigns)

          needed_assigns = if widget_class.extra_assigns == :use
            total_assigns
          else
            widget_class.extract_needed_assigns_from(total_assigns)
          end

          widget = widget_class.new(needed_assigns)
          template_handler.with_output_buffer do
            rendering_context = ::Fortitude::RenderingContext.new(:delegate_object => template_handler, :yield_block => block)
            widget.to_html(rendering_context)
            rendering_context.flush!
          end
        end
      end
    end
  end
end
