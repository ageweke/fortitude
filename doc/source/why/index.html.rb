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
                li {
                  text "You’ll build new views faster — and this pace will "
                  em "accelerate"
                  text " as your codebase grows, not decelerate."
                }
                li "You’ll have fewer bugs in your views, and spend less time debugging them."
                li {
                  text "You’ll "
                  em "enjoy"
                  text " building views much more."
                }
              }

              p {
                text %{Fortitude interoperates perfectly with existing templating engines
(like ERb or HAML).
You can start using it on new views or convert existing views at any pace you like.
It supports all modern versions of Ruby (1.8.7—2.2.}
                em "x"
                text %{, including JRuby), and all versions of Rails from 3.0.}
                em "x"
                text %{ through 4.2.}
                em "x"
                text "."
              }

              h3 "How Does it Work?"

              p {
                text %{Fortitude expresses your views as Ruby code. By doing this, it allows you to
bring all the power of Ruby to bear on your views. As they grow in size, difference this makes is enormous.}
              }

              p %{Let’s start with an example. This is a snippet of a realistic, moderately complex view written in ERb:}

              erb 'user_settings.html.erb', <<-EOS
<div class="row">
  <div class="col-sm-6 table_container">
    <h3>Your Settings</h3>

    <table id="user-settings">
      <thead>
        <tr>
          <th>Setting</th>
          <th>Value</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td class="setting">ID</td>
          <td class="setting setting-numeric"><%= @user.id %></td>
        </tr>
        <tr>
          <td class="setting">Name</td>
          <td class="setting setting-string"><%= @user.name %></td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
EOS
            }
            columns(:small => 2) { }
          }
        }
      end
    end
  end
end
