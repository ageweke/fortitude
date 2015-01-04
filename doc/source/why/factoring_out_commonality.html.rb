require 'source/why/example_page'

module Views
  module Why
    class FactoringOutCommonality < Views::Why::ExamplePage
      def example_intro
        p %{We’ll start small. In Fortitude (and unlike ERb, HAML, and friends), “helpers”
are nothing more than ordinary Ruby methods that use the exact same semantics as
the rest of Fortitude — and they can take blocks, too. We’ll use this to create
a helper method that is a great deal simpler (in both implementation and from the
caller’s perspective) than the equivalent using traditional templating engines.}
      end

      def example_description
        p %{Let’s start small. This is a piece of code that, combined with appropriate CSS,
renders an “icon button” — a button consisting of a small icon, with a tooltip available:}

        erb 'icon_button_instance_1.html.erb', <<-EOS
<a href='<%= conditional_refresh_url(:user => @user) %>' class="button icon refresh">
  <span class="button_text">
    <span>Refresh this page, <strong>only</strong> if content has changed</span>
  </span>
</a>
EOS

        p %{When rendered, this button looks something like the following when you hover over it:}

        featured_image 'why/icon_button.png'

        p {
          text %{Isn’t that attractive? In fact, it’s }
          em "so"
          text %{ attractive that we’d like to use it everywhere. As we do, however, we run into a problem: we are }
          a("repeating ourselves", :href => 'http://c2.com/cgi/wiki?DontRepeatYourself')
          text %{, which we know is bad.}
        }
      end

      def using_standard_engines
        p {
          text %{So, let’s factor it out into a partial using ERb. This should be easy, right? We just need to deal
with a few things:}
        }

        ul {
          li {
            text "The URL (the "
            code "href"
            text " parameter) is, of course, different in almost every case."
          }
          li {
            text %{Sometimes we need to add additional attributes }
            em "(e.g."
            text ", "
            code "onclick"
            text ", "
            code "data-*"
            text ", "
            em "etc."
            text ") to the "
            code "a"
            text " element, and sometimes not."
          }
          li {
            text "Sometimes we need to add additional CSS classes to the "
            code "a"
            text " element, and sometimes not."
          }
          li {
            text %{Sometimes the tooltip has static text inside it, sometimes HTML, sometimes user-supplied data,
and sometimes a combination of all of the above.}
          }
          li {
            text %{Sometimes we want to include an entire image as the tooltip (and nothing else);
other times, we want text.}
          }
        }

        p {
          text %{Given that, here’s what the resulting ERb looks like:}
        }

        erb '_icon_button.html.erb', <<-EOS
<a href="<%= target %>" class="button icon <%= icon_name %> <%= additional_classes if defined?(additional_classes) %> <%= (defined?(additional_attributes) ? additional_attributes || '').html_safe %>">
  <% if defined?(tooltip_image) && tooltip_image %>
    <img src="<%= tooltip_image %>" />
  <% else %>
    <span class="button_text">
      <% if defined?(tooltip_html) && tooltip_html %>
        <%= tooltip_html.html_safe %>
      <% else %>
        <%= tooltip_text %>
      <% end %>
    </span>
  <% end %>
</a>
EOS

        p %{Here’s the calling code in a simple case:}

        erb 'icon_button_simple_caller.html.erb', <<-EOS
<%= render :partial => '/shared/buttons/icon_button', :locals => {
  :target => conditional_refresh_url(:user => @user),
  :icon_name => 'refresh',
  :tooltip_text => "Refresh this page"
} %>
EOS

        p %{And here’s the calling code in a more complex case:}

        erb 'icon_button_complex_caller.html.erb', <<-EOS
<%= render :partila => '/shared/buttons/icon_button', :locals => {
  :target => conditional_refresh_url(:user => @user),
  :additional_classes => 'spinner_on_run background',
  :additional_attributes => 'onclick=""'
} %>
EOS


        p {
          text %{That’s pretty messy — the visual back-and-forth between the HTML and the
interpolated data alone is really distracting, and there are many different variables floating
around.}
        }
        p {
          text %{Here’s a challenge: by looking at the view, }
          strong "which variables must you pass in order to render this partial, and which ones are optional?"
          text %{ Now, consider that }
          em "every single programmer"
          text %{ who uses that view will have to figure out that list and get it right, every single time.}
        }
      end

      def using_fortitude
        h1 "nyi"
      end
    end
  end
end
