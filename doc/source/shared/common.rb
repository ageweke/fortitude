module Views
  module Shared
    module Common
      def retina_image(canonical_path, attributes = { })
        classes = retina_image_div_based_image_classes(canonical_path)
        div(*add_css_classes(classes, attributes))
      end

      def emphatic_pullquote(*args, &block)
        blockquote(*add_css_classes(:emphatic, *args), &block)
      end

      def small_pullquote(*args, &block)
        blockquote(*add_css_classes(:small, *args), &block)
      end

      def vertical_space
        div(:class => 'vertical-space')
      end

      def erb(title, the_code)
        source_code(:erb, title, the_code)
      end

      def fortitude(title, the_code)
        source_code(:rb, title, the_code)
      end

      def source_code(language, title, the_code)
        figure(:class => :source) {
          figcaption title
          pre(:class => language) {
            code the_code
          }
        }
      end

      def featured_image(image_path)
        retina_image(image_path, :class => 'featured_image')
      end
    end
  end
end
