module Fortitude
  module Tags
    class RenderWidgetPlaceholder
      attr_reader :render_args

      def initialize(render_args)
        @render_args = render_args
      end

      def name
        :_fortitude_render_widget_placeholder
      end

      def validate_can_enclose!(widget, tag_object)
        # nothing here, always OK
      end
    end
  end
end
