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
        def render(widget_class, template_handler, local_assigns, is_partial)
          $stderr.puts "template_handler foo: #{template_handler.instance_variable_get("@foo").inspect}"
          widget = widget_class.new(template_handler.assigns.merge(local_assigns).with_indifferent_access)
          template_handler.with_output_buffer do
            rendering_context = ::Fortitude::RenderingContext.new(:instance_variables_object => template_handler)
            widget.to_html(rendering_context)
            template_handler.output_buffer << rendering_context.output
          end
        end
      end
    end
  end
end
