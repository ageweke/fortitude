module Fortitude
  module Rails
    class Renderer
      class << self
        def render(widget_class, template_handler, local_assigns, is_partial)
          $stderr.puts "RENDER: #{widget_class.inspect}, #{local_assigns.inspect}, #{is_partial.inspect}"

          widget = widget_class.new(local_assigns)
          template_handler.with_output_buffer do
            $stderr.puts "WRITING TO: #{template_handler.output_buffer.class}"

            out = ""
            widget.to_html(out)
            template_handler.output_buffer.safe_concat(out)

            # Set parent and helpers to the view and use Rails's output buffer.
            # widget.to_html(options.merge(:helpers => view,
            #                              :parent  => view,
            #                              :output  => Output.new(:buffer => lambda { view.output_buffer })))
          end
        end
      end
    end
  end
end
