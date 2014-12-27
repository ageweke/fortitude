module Views
  module Why
    class Index < Views::Shared::Base
      def content
        container {
          jumbotron {
            h2 "Why use Fortitude?"
          }

          row {
            columns(:small => 3) { }
            columns(:small => 7) {
              p %{There is exactly one overwhelming reason to use Fortitude:}

              emphatic_pullquote %{It allows you to write vastly better-factored views.}

              p %{This means:}

              ul {
                li "You’ll be able to enhance, modify, and debug views much faster."
                li %{You’ll build new views faster — and this pace will accelerate as
your codebase grows, not decelerate.}
                li "You’ll have fewer bugs in your views, and spend less time debugging them."
                li {
                  text "You’ll "
                  em "enjoy"
                  text " building views much more."
                }
              }

              p %{Scroll down to see examples of some of the ways this allows you to build
dramatically more readable, efficient, maintainable, and enjoyable views.}

              vertical_space

              p {
                text %{Next to the power Fortitude gives you to factor your views, its other
benefits pale by comparison — it’s not that they’re insignificant, it’s that being able
to factor your views well is such a huge advantage that they’re small by comparison.
Even so, it’s worth listing these other benefits of Fortitude:}
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
forgetting to close a tag or mismatching tags.}
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
                  text "."
                }
                li {
                  strong "Formatting"
                  text %{: Fortitude can produce beautifully-formatted, perfectly-indented HTML — even across
view boundaries. Conversely, in production, it automatically produces highly-compressed HTML
to minimize page weight.}
                }
                li {
                  strong "Where did this come from?"
                  text %{ When working with a large codebase, it can be very frustrating trying to track
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

              h3 "How Does it Work?"

              p {
                text %{Fortitude expresses your views as Ruby code. By doing this, it allows you to
bring all the power of Ruby to bear on your views. As they grow in size, difference this makes is enormous.}
              }

              h4 "Factoring Out Commonality"

              p %{Let’s start small. This is a piece of code that, combined with appropriate CSS,
renders an “icon button” — a button consisting of a small icon, with a tooltip available if you
hover over it:}

              erb 'icon_button_instance_1.html.erb', <<-EOS
<a href='<%= conditional_refresh_page_url(:user => @user) %>' class="button icon refresh">
  <span class="button_text">
    <span>Refresh this page, <strong>only</strong> if content has changed</span>
  </span>
</a>
EOS

              p %{When rendered, this button looks something like the following when you hover over it:}

              img(:src => '/images/why/icon_button@2x.png')
            }
            columns(:small => 2) { }
          }
        }
      end
    end
  end
end
