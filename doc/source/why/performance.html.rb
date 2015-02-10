require 'source/why/example_page'

module Views
  module Why
    class Performance < Views::Why::ExamplePage
      def example_content
        performance_intro

      end

      def performance_intro
        p {
          text "How important is the performance of a templating engine to your Rails stack?"
        }

        p {
          text "Well, like most engineering questions, "; em "it depends"; text ":"
        }

        ul {
          li {
            text "For "; strong "scaling"; text ", views themselves are effectively never a bottleneck. They can "
            text "be trivially scaled horizontally by adding more threads, processes, or servers."
          }
          li {
            text "For "; strong "single-user latency"; text " — in other words, the speed that a single user actually "
            em "feels"; text " — views "; a "can be critical", :href => 'https://blog.kissmetrics.com/loading-time/'
            text ". Rendering views for a single user is an (almost) inherently "
            text "single-threaded process. And, aside from buying a CPU that’s faster at single-threaded operations ("
            a "which is getting harder and harder", :href => 'http://preshing.com/20120208/a-look-back-at-single-threaded-cpu-performance/'
            text "), there’s very little you can do to make it go faster."
          }
        }

        p {
          text "Perhaps most importantly: once you pick a templating engine, you’re likely to start building a "
          em "lot"; text " of code in it. "
        }
      end
    end
  end
end
