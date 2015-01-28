require 'source/why/example_page'

module Views
  module Why
    class WritingCorrectHtml < Views::Why::ExamplePage
      def example_content
        p {
          text "Quick — what’s wrong with the following code?"
        }

        erb <<-EOS
<div class="main-content">
  <div class="introduction">
    <h3>Introduction</h3>
    <p class="body">In the <em>very</em>beginning, the Web was nothing but <span class="highlighted">completely static</span>
       content. While static content was in many ways <div class="extra_emphasis">amazing</div> for the time,
       just because of the ease of use, it was not enough.</p>
    <p class="body">And so this begat the CGI. Someone realized that <strong>any program at all</strong> could generate
       HTML, and that was also <span class="highlighted">amazing</span>.</p>
  </div>
</div>
EOS

        p {
          text "Fortitude knows:"
        }
      end
    end
  end
end
