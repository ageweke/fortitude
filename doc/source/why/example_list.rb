module Views
  module Why
    module ExampleList
      EXAMPLES = begin
        out = [
          { :subpath => 'a_simple_helper', :title => 'A Simple Helper' }
        ]
        out.each_with_index do |hash, index|
          hash[:number] = (index + 1)
          hash[:path] = "/why/#{hash[:subpath]}.html"
        end
        out
      end

      def first_example
        EXAMPLES[0]
      end

      def number_of_examples
        EXAMPLES.length
      end

      def this_example_number
        this_example[:number] if this_example
      end

      def example_by_number(number)
        EXAMPLES.detect { |e| e[:number] == number }
      end

      def this_example
        @this_example ||= begin
          request_path = request[:path]
          request_path = "/#{request_path}" unless request_path.start_with?("/")

          out = EXAMPLES.detect { |e| e[:path] == request_path }
          out || :none
        end
        @this_example unless @this_example == :none
      end

      def example_title(example)
        "Example #{example[:number]}. #{example[:title]}"
      end

      def next_example
        @next_example ||= begin
          if this_example_number
            example_by_number(this_example_number + 1)
          else
            first_example
          end
        end
      end
    end
  end
end
