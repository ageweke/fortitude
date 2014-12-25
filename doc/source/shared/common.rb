module Views
  module Shared
    module Common
      def emphatic_pullquote(*args, &block)
        blockquote(*add_css_classes(:emphatic, *args), &block)
      end

      def vertical_space
        div(:class => 'vertical-space')
      end

      def erb(title, the_code)
        source_code(:erb, title, the_code)
      end

      def source_code(language, title, the_code)
        figure(:class => :source) {
          figcaption title
          pre(:class => language) {
            code the_code
          }
        }
      end
    end
  end
end
