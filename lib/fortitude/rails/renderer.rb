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
          total_assigns = template_handler.assigns.symbolize_keys.merge(local_assigns.symbolize_keys)

          needed_assigns = if widget_class.extra_assigns == :use
            total_assigns
          else
            widget_class.extract_needed_assigns_from(total_assigns)
          end

          widget = widget_class.new(needed_assigns)
          template_handler.with_output_buffer do
            rendering_context_options = { :delegate_object => template_handler, :yield_block => block }
            controller = template_handler.controller
            rendering_context = controller.fortitude_rendering_context(rendering_context_options)

            # TODO: Refactor this -- both passing it into the constructor and setting yield_block here is gross.
            #
            # We need to call #with_yield_block here, because we can actually be invoked with different yield blocks
            # in the case of "partial layouts" (which most people probably don't even realize exist); we use the same
            # RC for both the initial view rendering and for the partial layout, but they need different yield blocks.
            # Yuck, but this does the job.
            rendering_context.with_yield_block(block) do
              widget.to_html(rendering_context)
            end
            rendering_context.flush!
          end
        end
      end
    end
  end
end
