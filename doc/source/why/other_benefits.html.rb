module Views
  module Why
    class OtherBenefits < Views::Shared::Base
      def content
        container {
          jumbotron {
            h2 "Other Benefits of Fortitude"
          }

          row {
            columns(:small => 3) { }
            columns(:small => 7) {
              p {
                text %{Next to }
                a("the power Fortitude gives you to factor your views", :href => '/why')
                text %{, its other
benefits pale by comparison. It’s not that these advantages are even all that small,
it’s that being able to factor your views well is so important that it’s by far the biggest
reason to use Fortitude. Even so, it’s worth listing these other benefits of Fortitude:}
              }

              ul {
                li {
                  strong "Speed"
                  text %{: Fortitude is currently the fastest general-purpose templating engine
for Ruby — 20-40% faster than ERb, 4-5x faster than HAML, and 30-40x faster than Erector.}
                }
                li {
                  strong "Syntax"
                  text %{: Fortitude makes it impossible to make an HTML syntax error, like
forgetting to close a tag or mismatching tags. If your view parses as Ruby, you’re guaranteed
to produce syntactically-valid HTML.}
                }
                li {
                  strong "Semantics"
                  text %{: Fortitude can automatically enforce many of the rules
of HTML, like which elements can nest within which others (}
                  em "e.g."
                  text %{, you can’t put a }
                  code "<div>"
                  text " inside a "
                  code "<p>"
                  text "), which attributes an element can have (for example, "
                  code "<video>"
                  text " can have "
                  code "width"
                  text " and "
                  code "height"
                  text " attributes, but "
                  code "<audio>"
                  text " cannot), and — perhaps most usefully — that no two elements on a page can "
                  text "have the same "
                  code "id"
                  text %{. And when you make a mistake, you get an extremely clear error message, even
referring you to the proper part of the HTML specification to check what went wrong.}
                }
                li {
                  strong "Formatting"
                  text %{: Fortitude can produce beautifully-formatted, perfectly-indented HTML — even across
view boundaries. Conversely, in production, it automatically produces highly-compressed HTML
to minimize page weight.}
                }
                li {
                  strong "Traceability"
                  text %{: When working with a large codebase, it can be very frustrating trying to track
down which partial is responsible for generating a particular piece of content. In development,
Fortitude emits HTML comments above and below every partial, telling you exactly what's
being rendered and with what variable assignments — making it a piece of cake to figure
out which file you need to edit to change something.}
                }
                li {
                  strong "Interoperability"
                  text %{: Fortitude interoperates perfectly with your existing templating engine(s)
(like ERb or HAML) and views. You can start using it on new views, or convert existing views
at any pace you like. There’s even a tool, }
                  a(:href => "https://github.com/ageweke/html2fortitude") {
                    code "html2fortitude"
                  }
                  text ", that automatically converts ERb views to Fortitue."
                }
                li {
                  strong "Compatibility"
                  text %{: Fortitude is compatible with Ruby 1.8.7–2.2.}
                  em "x"
                  text %{, including JRuby, and all versions of Rails from 3.0.}
                  em "x"
                  text %{ through 4.2.}
                  em "x"
                  text %{. It also is fully compatible with the wonderful }
                  a("Tilt", :href => "https://github.com/rtomayko/tilt")
                  text %{ meta-templating framework, so any tool that uses Tilt can use Fortitude.
(For example, the documentation you’re reading right now was built using }
                  a("Middleman", :href => "http://middlemanapp.com/")
                  text ", using Fortitude as the templating engine.)"
                }
              }

              p {
                text %{Still not convinced? }
                a("Read more about how powerful it can be to factor your views well", :href => '/why')
                text "."
              }
            }
            columns(:small => 2) { }
          }
        }
      end
    end
  end
end
