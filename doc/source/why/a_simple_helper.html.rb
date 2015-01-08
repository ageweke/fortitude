require 'source/why/example_page'

module Views
  module Why
    class ASimpleHelper < Views::Why::ExamplePage
      def example_intro
        p %{Fortitude expresses your view code as Ruby itself, using a simple DSL patterned
after HTML. One big benefit of this approach is its consistency: views, helpers,
and partials are all written in the exact same language, Ruby.}

        p %{Ruby is a great deal nicer to
work with than either an HTML templating language or the string interpolation of traditional
helper methods. We’ll see the difference this can make in the following example.}
      end

      def example_description
        p %{The following ERb code was extracted from a real-world application, and is a great, simple
example of where Fortitude can help the most.}

        erb <<-EOS
...
<a href='<%= conditional_refresh_url(:user => @user) %>'
   class="button icon refresh" onclick="javascript:handleRefreshClick();">
  <div class="button_text">
    <p>Refresh this page if:</p>
    <ul>
      <li>Content has changed</li>
      <li>Local data is <%= @out_of_date_condition %></li>
    </ul>
  </div>
</a>
...
EOS

        p %{Combined with appropriate CSS, this code creates an “icon button” — a small icon, with a tooltip available:}

        featured_image 'why/icon_button.png'

        p {
          text %{Unsurprisingly, this button gets used in }; em "many"; text %{ places throughout the application. }
          text %{Using ERb, let’s see what we can do to factor out this common pattern.}
        }
      end

      def using_standard_engines
        refactoring_choices
        using_a_helper
        using_a_partial
      end

      def refactoring_choices
        p %{Using traditional templating engines, we have two choices:}

        ul {
          li {
            text "We can create a "; em "helper"; text ", which is written using Ruby string interpolation and called "
            text "like a traditional Ruby method;"
          }
          li {
            text "Or we can create a "; em "partial"; text ", which is written using our templating language of choice "
            text "and called using "; code "render :partial => ..."; text "."
          }
        }

        p %{In either case, we’ll need to make sure we allow for several variations in our desired output:}

        ul {
          li {
            text "The URL (the "; code "href"; text " parameter) is, of course, different in almost every case."
          }
          li {
            text %{Sometimes we need to add additional attributes }; em "(e.g."; text ", "; code "onclick"; text ", "
            code "data-*"; text ", "; em "etc."; text ") to the "; code "a"; text " element, and sometimes not."
          }
          li {
            text %{What’s inside the tooltip varies: it can be plain text or HTML, it can have variable substitutions —
really, it can be anything at all.}
          }
        }

        p %{Given these constraints, let’s see how each of these looks.}
      end

      def using_a_helper
        h5 "Using a Helper"

        p %{Here’s what our new helper method looks like:}

        ruby "application_helper.rb", <<-EOS
def icon_button(icon_name, target, tooltip_html, additional_attributes_string = "")
  "<a href=\"\#{target}\" class="button icon \#{icon_name}" \#{additional_attributes_string}><div class="button_text">\#{tooltip_html}</div></a>"
end
EOS

        p %{And here’s how we’d call it for the example above:}

        erb <<-EOS
...
<%= icon_button(:refresh, conditional_refresh_url(:user => @user), "<p>Refresh this page if:</p><ul><li>Content has changed</li><li>Local data is \#{h(@out_of_date_condition)}</li></ul>", "onclick=\"javascript:handleRefreshClick();\"")
EOS

        p "What’s good and what’s bad about this?"

        ul {
          li {
            strong "Concise"; text ": Both the caller and helper are quite short; but:"
          }
          li {
            strong "Inconsistent"; text ": Suddenly, we’re forced to write both the helper method "; em "and"
            text " the HTML for the interior of the button using Ruby string interpolation, rather than ERb — "
            text "which leads to:"
          }
          li {
            strong "Messy"; text ": We have significant stretches of HTML sitting around in Ruby strings, "
            text "which is quite hard to read;"
          }
          li {
            strong "Bad Formatting"; text ": Because of this, the generated HTML will be quite poorly formatted, "
            text "with the HTML in those strings all run-together. But, most importantly:"
          }
          li {
            strong { em "Dangerous (XSS Potential)" }; text ": We’re now responsible for worrying about HTML escaping "
            text "in a way we weren’t before: "; em "every single caller"; text " needs to make sure that any user "
            text "data in the "; code "additional_attributes_string"; text " is escaped "; em "before"; text " being "
            text "passed. Similarly, we need to remember to call "; code "h()"; text " on the variable being "
            text "interpolated into the "; code "tooltip_html"; text " string before passing it, or else we’ll be "
            text "vulnerable to XSS attacks again."
          }
        }

        p {
          text "Yikes. We’ve factored out this helper method, which cleans up our calling code, but at a rather significant "
          text "expense. Perhaps we can do better by creating an actual partial, instead?"
        }
      end

      def using_a_partial
        h5 "Using a Partial"

        p %{Here’s what our new partial looks like:}

        erb <<-EOS
<a href="<%= target %>" class="button icon <%= icon_name %>"
   <%= (defined?(additional_attributes) ? additional_attributes || '') %>">
  <div class="button_text">
    <%= tooltip_html %>
  </div>
</a>
EOS

        p %{And here’s how we’d call it for the example above:}

        erb <<-EOS
<%= render :partial => '/shared/buttons/icon_button', :locals => {
  :target => conditional_refresh_url(:user => @user),
  :icon_name => 'refresh',
  :additional_attributes => 'onclick="javascript:handleRefreshClick();"'.html_safe,
  :tooltip_html => %{<p>Refresh this page if:</p>
    <ul>
      <li>Content has changed</li>
      <li>Local data is \#{h(@out_of_date_condition)}</li>
    </ul>}.html_safe
} %>
EOS

        p "Again, what’s good and what’s bad about this?"

        ul {
          li {
            strong "Consistency/Inconsistency"; text ": on one hand, at least now the partial itself is expressed using "
            code "ERb"; text ", not a Ruby string. On the other hand, we still have to use a Ruby string for the HTML we’re "
            text "passing in to it."
          }
          li {
            strong "Verbose and Messy"; text ": we’ve actually managed to create a caller that is 33% "
            em "longer"; text " than the original code it replaced, and is actually quite a lot harder to read at "
            text "first glance. (The helper method was a lot better here.)"
          }
          li {
            strong "Formatting"; text ": the resulting HTML will at least look a lot better than in our earlier example;"
          }
          li {
            strong "Method Signature"; text ": when reading the new "; code "_icon_button.html.erb"; text "partial, "
            text "how can you easily tell which variables you need to pass in, and which of those are optional? "
            em "You can’t"; text " — except by reading through the entire text of the partial and thinking about "
            text "each use carefully, which is really painful. (In this, the helper method was certainly "
            text "a lot cleaner, too.)"
          }
          li {
            strong { em "Dangerous (XSS Potential)" }; text ": Once again, we’re now responsible for worrying about "
            text "HTML escaping in a way we weren’t before: "; em "every single caller"; text " needs to make sure that "
            text "any user data in the "; code "tooltip_html"; text " string is correctly escaped using "; code "h()"
            text " before being passed in. (We also need to make sure we call "; code "#html_safe"; text " on the "
            text "value we pass to "; code "additional_attributes"; text ", too; this is less dangerous, but also very "
            text "easy to forget, and will cause corrupt HTML if we forget about it.)"
          }
        }
      end

      def standard_engine_issues
        p {
          text "Both cases above are far from perfect. Helper methods are more succinct to call, yet also a lot "
          text "messier to both write and call when passing around HTML, and have serious XSS risks. Partials mitigate "
          text "some of those problems, but introduce others, and are "; em "really"; text " verbose and messy to call."
        }

        p {
          text "Ironically, some of the issues above may feel a little unfamiliar, and it’s probably because of this: "
          em "nobody does this"; text " — because both these approaches have such serious tradeoffs, most teams, "
          text "developers, or designers just leave well enough alone for small(ish) examples like this, and "
          text "repeat the original HTML everywhere, over "
          text "and over. And when it comes time to change the "
          text "HTML structure of this “icon button” element that’s been repeated all over the site, we either just "
          text "bite the bullet and do a really painful global search and repeated manual modificaftion, or give up, "
          text "hack on CSS to make it do sort of what we want it to do, and then leave "; em "that"
          text " mess in place."
        }

        p {
          text "We imagine that this is "; em "just the way views are"; text ". "
          text "In fact, these problems are all because we generally don’t have the right tools to do a better job. "
          text "Views don’t need to be like this, any more than "; em "any"; text " code needs to be like this."
        }
      end

      def using_fortitude
        p %{To see what Fortitude brings to this example, let’s start by looking at Fortitude code for the original
example, before we try to refactor it:}

        fortitude <<-EOS
...
a(:href => conditional_refresh_url(:user => @user),
  :class => 'button icon refresh') {
  div(:class => 'button_text') {
    p "Refresh this page if:"
    ul {
      li "Content has changed"
      li "Local data is \#{@out_of_date_condition}"
    }
  }
}
...
EOS

        p {
          text %{We won’t delve more deeply into Fortitude’s syntax immediately, but it should be clear that
Fortitude expresses HTML using a very simple Ruby DSL that’s easy to grasp.}
        }

        p {
text %{Using this syntax, we can now factor out this shared code as a “helper method” that
we can easily make available on any view that needs it.}
        }

        p {
          text "(We put “helper method” in quotes because "
          text "this isn’t a traditional helper that we’d put into something like "
          code "app/helpers/application_helper.rb"; text " and write using Ruby string interpolation. Rather, it’s a "
          text "method we define in a module, and mix into any view class that needs it — Fortitude views are actually "
          text "just normal Ruby classes — or into our base view class to make it magically available everywhere.)"
        }

        p {
          text "Using this strategy, we can create the following “helper method”:"
        }

        fortitude <<-EOS
def icon_button(icon_name, target, additional_attributes = { })
  a(additional_attributes.merge(
    :href => target, :class => "button icon \#{icon_name}")) {
    div(:class => :button_text) {
      yield
    }
  }
end
EOS

        p "And the calling code for the example above now looks like this:"

        fortitude <<-EOS
...
icon_button('refresh', conditional_refresh_url(:user => @user),
  :onclick => 'javascript:handleRefreshClick();') {
  p "Refresh this page if:"
  ul {
    li "Content has changed"
    li "Local data is \#{@out_of_date_condition}"
  }
}
...
EOS
      end

      def fortitude_benefits
        p %{Let’s take a look at how much cleaner this is. A few of the most obvious improvements:}

        ul {
          li {
            strong "Concise"; text %{: The calling code is now actually both much }; em "shorter"; text " and "
            em "more expressive"; text " than the code it replaced."
          }
          li {
            strong "Consistent"; text ": both the new “helper method” and its caller are written in the same "
            text "language — which is the same language you use for all Fortitude code and the entire rest of your "
            text "application, Ruby."
          }
          li {
            strong "Well-Formatted"; text ": Because Fortitude is not interpolating strings, but, rather, understands the "
            text "structure of the HTML, all output is perfectly formatted. (In development, it’s indented correctly, "
            text "no matter how the code is written; in production, it is automatically produced with minimal spacing, "
            text "to reduce the size of the HTML transmitted across the network.)"
          }
          li {
            strong "Clean and Clear"; text ": Because it’s a Ruby method, any Ruby programmer will instantly understand "
            text "what needs to be passed to it; because all of the code is Ruby, it all reads cleanly and clearly."
          }
          li {
            strong { em "Safe" }; text ": at no point does any caller, nor the method itself, need to worry about HTML "
            text "escaping; all data will be escaped properly without worrying about it."
          }
        }

        p {
          text "However, one of the biggest improvements we’ve made is slightly more subtle: by creating this new "
          code "icon_button"; text " method, we’ve started slowly building up a "; em "customized view language"
          text " that is specific to our needs and our application. As we proceed through further examples, we’ll see "
          text "how powerful this can be in creating clean, concise, maintainable views that are a joy to use."
        }
      end
    end
  end
end
