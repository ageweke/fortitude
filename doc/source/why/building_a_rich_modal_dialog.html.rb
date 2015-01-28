require 'source/why/example_page'

module Views
  module Why
    class BuildingARichModalDialog < Views::Why::ExamplePage
      def example_intro
        p {
          text "In our last example, we saw how using inheritance lets you easily solve view-factoring problems "
          text "with Fortitude that remain painful in traditional templating engines. In this example, we’ll see "
          text "how Fortitude’s widget classes let us create specialized contexts for rendering parts of views. "
          text "In effect, they become little mini-languages, introducing view primitives exactly "
          text "when you need them and providing an elegant language for you to describe what your view should "
          text "look like."
        }
      end

      def example_description
        p {
          text "Almost everybody knows the concept of a "; em "modal dialog"; text " — a “layer” of HTML that "
          text "requests some kind of input or confirmation from the user before proceeding, and which obscures "
          text "the rest of the web page so that the user is forced to provide this input or confirmation before "
          text "proceeding. They’re often also known as a "; em "lightbox"; text ", "; em "modal window"; text ", or "
          em "heavy window"; text ", and have become a staple of modern Web design."
        }

        p {
          text "Here’s an example of a modal dialog that appears in Google Docs when you choose “Make a Copy”: "
        }

        featured_image 'why/modal_dialog.png'

        p {
          text "This simple example has a number of features that modal dialogs tend to share:"
        }

        ul {
          li "A clear border, often with a drop shadow, around the entire dialog."
          li "A large layer that dims or otherwise obscures the rest of the page behind the dialog."
          li "Some kind of “close” or “dismiss” control, often in the upper-right-hand corner."
          li "A title of some kind at the top — sometimes styled, sometimes not."
          li "Primary content, which can be more-or-less arbitraily complex."
          li "At the bottom, at least one button (“OK”), and often more than one."
        }

        p {
          text "These simple dialogs present an interesting challenge for view builders. Even the frame of the dialog "
          text "will consist of multiple elements (usually "; code "div"; text "s), with some important CSS classes "
          text "applied. There will be a standard way of creating the title, and likely a container that the primary "
          text "content needs to go into. The buttons at the bottom will typically have their own container and styles, "
          text "and standard ways of rendering them."
        }

        p {
          text "Let’s look at an example modal dialog in completely non-refactored (one-off) HTML:"
        }

        erb 'app/views/docs/copy_document.html.erb', <<-EOS
<div class="modal-background copy_document_modal">
  <div class="modal-dialog">
    <div class="window-controls"><span class="dialog-control">X</span></div>
    <div class="modal-title">
      <h3>Copy document</h3>
    </div>

    <div class="modal-contents">
      <form class="modal-form">
        <label for="document_name">Enter a new document name:</label>
        <input type="text" name="document_name">Copy of Untitled document</input>
        <span class="form-input-footnote">Comments will not be copied to the new document.</span>

        <input type="checkbox" name="copy_sharing"></input>
        <label for="copy_sharing">Share it with the same people</label>
      </form>
    </div>

    <div class="modal-actions">
      <button name="OK" value="ok" class="modal-button">OK</button>
      <button name="Cancel" value="cancel" class="modal-button">Cancel</button>
    </div>
  </div>
</div>
EOS
      end

      def using_standard_engines
        p {
          text "Using traditional templating engines, what’s the best we can do with this? In many ways, it’s similar "
          text "to our previous example: we can either use partials/helpers for shared structural elements and count "
          text "on calling them in the right order, or use "; code "capture"; text " to construct blocks of HTML and "
          text "pass them into a shared view."
        }

        p {
          text "One of the big differences here is that the chunks of HTML we pass in themselves need certain "
          text "predefined structure. For example, the modal title may need to be in a certain format (at least most "
          text "of the time), and the set of buttons at the bottom may need certain classes, and so on."
        }

        p {
          text "Without further ado, let’s see what the end result looks like:"
        }


        erb 'app/views/docs/copy_document.html.erb', <<-EOS
<% the_modal_title = capture do %>
  <%= modal_title("Copy document") %>
<% end %>

<% the_modal_contents = capture do %>
  <%= modal_form_start %>
    <label for="document_name">Enter a new document name:</label>
    <input type="text" name="document_name">Copy of Untitled document</input>
    <span class="form-input-footnote">Comments will not be copied to the new document.</span>

    <input type="checkbox" name="copy_sharing"></input>
    <label for="copy_sharing">Share it with the same people</label>
  <%= modal_form_end %>
<% end %>

<%= render :partial => '/shared/modal_dialog', :locals => {
  :outer_css_class => 'copy_document_modal',
  :title_html => the_modal_title,
  :contents_html => the_modal_contents,
  :buttons => { 'OK' => 'ok', 'Cancel' => 'cancel' }
}
%>
EOS

        p {
          text "And our shared modal dialog partial:"
        }

        erb 'app/views/shared/_modal_dialog.html.erb', <<-EOS
<div class="modal-background <%= outer_css_class %>">
  <div class="modal-dialog">
    <% if defined?(include_close) && include_close %>
      <div class="window-controls"><span class="dialog-control">X</span></div>
    <% end %>
    <div class="modal-title">
      <%= title_html.html_safe %>
    </div>

    <div class="modal-contents">
      <%= contents_html.html_safe %>
    </div>

    <div class="modal-actions">
      <% buttons.each do |title, value| %>
        <button name="<%= title %>" value="<%= value %>" class="modal-button"><%= title %></button>
      <% end %>
    </div>
  </div>
</div>
EOS

        p {
          text "And, finally, our helpers:"
        }

        erb 'app/helpers/application_helper.rb', <<-EOS
  # ...
  def modal_title(text)
    "<h3>\#{text}</h3>"
  end

  def modal_form_start
    "<form class=\\"modal_form\\">"
  end

  def modal_form_end
    "</form>"
  end
  # ...
EOS
      end

      def standard_engine_issues
        p {
          text "Have we achieved what we want with a traditional templating engine? Yes. Is it pretty? No."
        }

        p {
          text "In particular, we can see quite a few places where this code is pretty messy:"
        }

        ul {
          li {
            strong "Caller Structure"; text ": Our calling view has to pull together two separate chunks of HTML using "
            code "capture"; text ", then pass them into the partial it invokes. The source code doesn’t reflect the "
            text "structure of the resulting output."
          }
          li {
            strong "Library Structure"; text ": Our modal-dialog partial is now split up between two different files — "
            text "one written using ERb and one in normal Ruby, and living in two completely separate directories. "
            text "(What is the probability that if someone moves one, they’ll move the other? If they delete "
            code "_modal_dialog.html.erb"; text ", they’ll remember to remove those helper methods?)"
          }
          li {
            strong "Helper Prefixes"; text ": Because our helpers are available "; em "everywhere"; text " (because we "
            text "need modal dialogs from lots of different controllers’ views), we need to prefix them with some kind "
            text "of consistent string, and make sure they don’t conflict with any of the other many helpers in our "
            text "overall "; code "application_helper.rb"; text " file."
          }
          li {
            strong "Customizability"; text ": Once again, adding customization to this “library” means adding more and "
            text "more options that you can pass in to the partial. The partial becomes the union of all desired "
            text "customizations across all callers."
          }
        }
      end

      def using_fortitude
        p {
          text "OK, OK. How much better can Fortitude make this? Here’s our caller, written in Fortitude:"
        }

        fortitude 'app/views/docs/copy_document.html.rb', <<-EOS
class Views::Docs::CopyDocument < Views::Base
  def content
    widget Views::Shared::ModalDialog.new(:outer_css_class => 'copy_document_modal') do
      title 'Copy document'

      form {
        label "Enter a new document name:", :for => :document_name
        input "Copy of Untitled document", :type => :text, :name => :document_name

        footnote "Comments will not be copied to the new document."

        input :type => :checkbox, :name => :copy_sharing
        label "Share it with the same people", :for => :copy_sharing
      }

      buttons {
        button 'OK'
        button 'Cancel'
      }
    end
  end
end
EOS

        p {
          text "And here’s our shared code:"
        }

        fortitude 'app/views/shared/modal_dialog.html.rb', <<-EOS
class Views::Shared::ModalDialog < Views::Base
  needs :outer_css_class, :include_close => true

  def content
    wrapper {
      controls

      yield
    }
  end

  def wrapper
    div(:class => [ 'modal-background', outer_css_class ]) {
      div(:class => 'modal-dialog') {
        yield
      }
    }
  end

  def controls
    div(:class => 'window-controls') {
      span "X", :class => 'dialog-control'
    }
  end

  def title(s)
    h3 s
  end

  def form
    div(:class => 'modal-contents') {
      form(:class => 'modal-form') {
        yield
      }
    }
  end

  def footnote(s)
    span s, :class => 'form-input-footnote'
  end

  def buttons
    div(:class => 'modal-actions') {
      yield
    }
  end

  def button(title, value = nil)
    value ||= title.downcase
    button(title, :name => title, :value => value, :class => 'modal-button')
  end
end
EOS
      end

      def fortitude_benefits
        p {
          text "What have we done here?"
        }

        p {
          text "In effect, we’ve used Fortitude to introduce a miniature "
          a("DSL", :href => 'https://en.wikipedia.org/wiki/Domain-specific_language')
          text ", designed specifically for creating modal dialogs. In this language, certain terms get redefined — "
          code "title"; text " and "; code "form"; text " "; em "conceptually"; text " mean the same thing, but cause "
          text "different output than they would in ordinary HTML — while we’ve also added new concepts like "
          code "footnote"; text "."
        }

        p {
          text "Fortitude’s widget system lets us scope this DSL precisely: within the context of the "
          code "ModalDialog"; text " widget and blocks passed to it, we redefine "; code "title"; text " and "
          code "form"; text ", and add "; code "footnote"; text ", but, elsewhere, they revert back to their standard "
          text "meanings (or no meaning at all, in the case of "; code "footnote"; text ")."
        }

        p {
          text "And, as you might imagine, the sky is the limit: because Fortitude is built with all the same tools "
          text "as standard Ruby, you have full control over exactly how this works, and can implement in any way you "
          text "can imagine:"
        }

        ul {
          li {
            text "Want to introduce a new "; code "sidebar"; text " primitive that works across your whole application? "
            text "You can. Just add it to your base widget class, and you’re all set."
          }

          li {
            text "Want to introduce a new "; code "user_history"; text " method that works only in your admin views? "
            text "Easy — if you have a base widget class all your admin views inherit from, add it there, or else put "
            text "it in a module and mix it in to any admin view that needs it."
          }

          li {
            text "HTML has "; code "strong"; text " for bold text and "; code "em"; text " for italics. Wish it had "
            text "a "; code "highlighted"; text " primitive to give you text on a colored background? With about "
            text "three lines of Fortitude code and three lines of CSS, it does now."
          }

          li {
            text "Find it easier to read the old-style HTML "; code "b"; text " text than the now-correct "; code "strong"
            text "? Again, about three lines of Fortitude code will mean you can write "; code "b"; text ", but get "
            text "HTML5-correct "; code "strong"; text " instead."
          }

          li {
            text "What if you have a table that’s conceptually the same, but should be rendered differently in "
            text "different parts of your site? Write the two different versions with the same name in two different "
            text "modules, then mix them in where appropriate. Now you can move calling code seamlessly between the "
            text "two different sides, and you’ll always get the right output."
          }

          li {
            text "Properly worried about the lack of Web encryption, and want to make sure all your off-site links are "
            text "using HTTPS? You can override Fortitude’s built-in "; code "a"; text " method to inspect the passed "
            text "parameters, and emit a warning or error in development mode if it’s non-SSL. This is also about five "
            text "lines of code."
          }

          li {
            text "Using Twitter’s excellent "; a "Bootstrap", :href => 'https://getbootstrap.com'; text " library?"
            text " While it’s succinct enough already, it’s a lot nicer to write "; code "row { ... }"; text " than "
            code "<div class='row'>...</div>"; text ". Again, this is a very small amount of code in Fortitude."
          }
        }

        p {
          text "Hopefully this gives you a taste of all of the different things you can easily do with Fortitude. "
          text "Using Fortitude, you can sculpt your view language to your own needs, both on a site-wide basis "
          text "and in specific contexts. It’s an immensely powerful tool for building far cleaner views — not only "
          text "making them more readable and maintainable, but also a whole lot more "; em "fun"; text "."
        }

        p {
          text "Next, we’ll take a look at some of the other benefits Fortitude offers beyond the abilities it gives "
          text "you to factor your code."
        }
      end
    end
  end
end
