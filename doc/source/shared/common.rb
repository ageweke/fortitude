module Views
  module Shared
    module Common
      def emphatic_pullquote(*args, &block)
        blockquote(*add_css_classes(:emphatic, *args), &block)
      end

      def vertical_space
        div(:class => 'vertical-space')
      end
    end
  end
end
