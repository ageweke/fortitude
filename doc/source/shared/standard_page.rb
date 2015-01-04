module Views
  module Shared
    class StandardPage < Views::Shared::Base
      def content
        container {
          page_content
        }
      end

      def page_content
        raise "Must override in #{self.class.name}"
      end

      def big_title(title = nil)
        jumbotron {
          if block_given?
            yield
          else
            h2 title
          end
        }
      end

      def standard_text_row(&block)
        row {
          columns(:small => 3)
          columns(:small => 7, &block)
          columns(:small => 2)
        }
      end

      def heading_row(&block)
        row {
          columns(:small => 3)
          columns(:small => 9, &block)
        }
      end
    end
  end
end
