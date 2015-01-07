require 'source/why/example_page'

module Views
  module Why
    class ASimpleHelper < Views::Why::ExamplePage
      def example_intro
        p %{Fortitude expresses your view code as Ruby itself, using a simple DSL patterned
after HTML. This allows you to factor your views in extremely powerful ways.}

        p %{We’ll start small. In Fortitude (and unlike ERb, HAML, and friends), “helpers”
are nothing more than ordinary Ruby methods that use the exact same semantics as
the rest of Fortitude — and they can take blocks, too. We’ll use this to create
a helper method that is a great deal simpler (in both implementation and from the
caller’s perspective) than the equivalent using traditional templating engines.}
      end

      def example_description
        p %{This is a piece of code that, combined with appropriate CSS,
renders an “icon button” — a button consisting of a small icon, with a tooltip available:}

        erb <<-EOS
...
<a href='<%= conditional_refresh_url(:user => @user) %>' class="button icon refresh">
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
            text %{What’s inside the tooltip varies: sometimes it’s plain text, sometimes it’s HTML,
sometimes it’s an image — really, it can be anything at all. And sometimes there are variable
substitutions in that data.}
          }
        }

        p {
          text %{Given that, here’s what the resulting ERb looks like for our new partial:}
        }

        erb <<-EOS
<a href="<%= target %>" class="button icon <%= icon_name %>" <%= (defined?(additional_attributes) ? additional_attributes || '') %>">
  <div class="button_text">
    <%= tooltip_html %>
  </div>
</a>
EOS

        p %{And here’s the calling code:}

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
      end

      def standard_engine_issues
        p %{Even though this is a simple example, this is already quite messy. Let’s try to enumerate the
problems we see, starting with the new partial (which is by far the least problematic
of the two sides of this approach):}

        ul {
          li {
            strong "Passed Variables"
            text %{: The }
            code "defined?(additional_attributes)"
            text %{ is ugly and very un-Ruby-like, and yet we need this if we want to make passing the }
            code "additional_attributes"
            text %{ parameter optional. (Yes, there are other ways of doing this, too — but they’re all pretty ugly.)}
          }
          li {
            strong "Method Signature"
            text %{: If you look at the }
            code '_icon_button.html.rb'
            text %{ file, how can you tell which variables you need to pass to it? }
            em "You can’t"
            text %{ — you just have to examine the entire text of the partial to see what it happens to use,
and investigate to see if those are variables used by the partial internally,
variables you’re required to pass using }
            code ":locals"
            text %{, or variables that optionally can be passed.}
          }
          li {
            strong "HTML Escaping"
            text %{: Both the }
            code "additional_attributes"
            text " and "
            code "tooltip_html"
            text " parameters, since they can contain HTML, must be declared "
            code "html_safe"
            text " by the caller. And if you forget? In the case of "
            code "tooltip_html"
            text ", you’ll get raw HTML rendered into your output. In the case of "
            code "additional_attributes"
            text %{, it’s even worse: you’ll generate serious HTML syntax errors. (Which your browser will
likely ignore for you…which is convenient until you spend quite a bit of time trying to
debug why your }
            code "onclick"
            text %{ declaration doesn’t work, only to find out it’s not even being inserted properly.)}
          }
        }

        p %{The calling code, however, is much worse:}

        ul {
          li {
            strong "Verbosity"
            text %{: First and foremost, we have managed to build a caller that is 33% }
            em "longer"
            text %{ than the original code it replaced. Although making code shorter is not the only point of
refactoring, we’d sure like a call to a helper like this to be shorter than just inlining the results of the method!}
          }
          li {
            strong "HTML Escaping"
            text %{: }
            em "Every single caller"
            text %{ needs to remember to call }
            code "html_safe"
            text %{ on the }
            code "additional_attributes"
            text " and "
            code "tooltip_html"
            text " parameters; if not, you’ll end up with raw HTML or corrupt HTML, as mentioned above."
          }
          li {
            strong "HTML Escaping, Part II"
            text %{: When we go to interpolate the }
            code "@out_of_date_condition"
            text %{ parameter into our }
            code "tooltip_html"
            text %{, we now need to worry about calling }
            code "h()"
            text %{ — and if we don’t, we’re now vulnerable to XSS attacks. This is not good.}
          }
        }

        p {
          text %{To the extent these issues seem unfamiliar, it’s probably because of this: }
          em "nobody does this"; text %{ — meaning most engineers or teams wouldn’t do this refactoring in the first place.}
        }

        p {
          text %{Why? It’s not because there are no benefits from refactoring out this commonality —
those benefits are every bit as big as they are with refactoring any kind of code, anywhere.
Rather, it’s because the tools that you’re given make the refactored code arguably }
          em "worse"
          text %{ than just repeating yourself everywhere. (Which has its own whole set of serious
downsides; it’s just that most engineers accept this as “just the way things are” when it comes
to building views.)}
        }

        p %{In reality, most teams simply leave well enough alone, and suffer the pains
of repeating themselves and the consequent difficulty of refactoring.}

        p "But there is a better way."
      end

      def using_fortitude
        p %{First off, let’s look at the Fortitude code for the original example, before we try to
refactor it:}

        fortitude <<-EOS
...
a(:href => conditional_refresh_url(:user => @user), :class => 'button icon refresh') {
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
Fortitude expresses HTML using a very simple Ruby DSL that’s easy to grasp.
Using this syntax, we can now factor out this shared code as a simple method that
we can easily make available on any view that needs it:}
        }

        fortitude <<-EOS
def icon_button(icon_name, target, additional_attributes = { })
  a(additional_attributes.merge(:href => target, :class => "button icon \#{icon_name}")) {
    div(:class => :button_text) {
      yield
    }
  }
end
EOS

        p "And now our caller looks like this:"

        fortitude <<-EOS
...
icon_button('refresh', conditional_refresh_url(:user => @user), :onclick => 'javascript:handleRefreshClick();') {
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
            strong "Verbosity"
            text %{: Our caller is now actually both (much) }
            em "shorter"
            text " and "
            em "more expressive"
            text " than the code it replaced."
          }
          li {
            strong "Passed Variables"
            text %{: with one look, you can see what you need to pass to the }
            code "icon_button"
            text %{ method, including what’s required and what’s optional — using the exact same
syntax you use for the rest of your application.}
          }
          li {
            strong "HTML Escaping"
            text %{: All of our HTML-escaping issues have simply vanished. We can completely ignore
this, and it will all “do the right thing”.}
          }
        }

        p {
          text %{However, one of the biggest improvements we’ve made is slightly more subtle: in the }
          code "ERb"; text %{ partial above, the }; code "tooltip_html"; text %{ parameter is created using ordinary }
          text "Ruby string interpolation, which is a totally different language than the rest of ERb (and, for this "
          text "purpose, is considerably less flexible). This happens because the “language” you write the rest of your "
          text "markup in — unescaped HTML — is completely different from the language you write partial and helper "
          text "calls in, Ruby."
        }

        p {
          text %{In Fortitude, these two languages are one and the same. In our next example, we’ll see how this
makes all the difference in the world with just one small change to our example.}
        }
      end
    end
  end
end
