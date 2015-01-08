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

      def erb(*args)
        source_code(:erb, *args)
      end

      def fortitude(*args)
        source_code(:rb, *args)
      end

      def ruby(*args)
        source_code(:rb, *args)
      end

      def source_code(language, *args)
        title = args.shift if args.length > 1
        the_code = args.shift
        raise ArgumentError, "Too many arguments: #{args.inspect}" if args.length > 0

        figure(:class => :source) {
          figcaption title if title
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
