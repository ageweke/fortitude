require 'source/shared/standard_page'
require 'source/why/example_list'

module Views
  module Why
    class ExamplePage < Views::Shared::StandardPage
      include Views::Why::ExampleList

      css %{
        .example_link {
          font-family: $heading-font;

          .next {
            font-weight: $heading-font-light-weight;
            font-size: 18px;
            margin-right: 10px;
          }

          a {
            font-weight: $heading-font-heavy-weight;
            font-size: 20px;
          }

          padding: 20px;
          margin-left: auto;
          margin-right: 0;
          margin-top: 40px;
          margin-bottom: 40px;

          background-color: $bold-translucent;

          text-align: right;
        }

        h4 { margin-top: 25px; }
      }

      def page_content
        big_title "Why use Fortitude?"
        example_body
      end

      def example_body
        standard_text_row {
          show_example_title
          example_intro

          section {
            h4 "What We’re Trying To Do"
            example_description
          }

          section {
            h4 "Using Standard Templating Engines"
            using_standard_engines
          }

          section {
            h4 "Issues with Standard Templating Engines"
            standard_engine_issues
          }

          section {
            h4 "Using Fortitude"
            using_fortitude
          }

          section {
            h4 "The Benefits"
            fortitude_benefits
          }

          link_to_next_example if next_example
        }
      end

      def show_example_title
        h3 example_title(this_example)
      end

      def example_intro
        raise "Must override in #{self.class.name}"
      end

      def example_description
        raise "Must override in #{self.class.name}"
      end

      def using_standard_engines
        raise "Must override in #{self.class.name}"
      end

      def standard_engine_issues
        raise "Must override in #{self.class.name}"
      end

      def using_fortitude
        raise "Must override in #{self.class.name}"
      end

      def fortitude_benefits
        raise "Must override in #{self.class.name}"
      end

      def link_to_next_example
        e = next_example
        div(:class => 'example_link') {
          span "next", :class => 'next'
          a(:href => e[:path]) {
            text example_title(e)
          }
        }
      end
    end
  end
end
