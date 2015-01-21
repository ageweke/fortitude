require 'source/why/example_page'

module Views
  module Why
    class BuildingARichModalDialog < Views::Why::ExamplePage
      def example_intro
        p {
          text "In our last example, we saw how using inheritance lets you easily solve view-factoring problems "
          text "with Fortitude that remain painful in traditional templating engines. In this example, we’ll see "
          text "how Fortitude’s widget classes let us create specialized contexts for rendering views that are "
          text "very powerful. In effect, they become little mini-languages, introducing view primitives exactly "
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
          text "applied. There will be a standard way of creating tht title, and likely a container that the primary "
          text "content needs to go into. The buttons at the bottom will typically have their own container and styles, "
          text "and standard ways of rendering them."
        }

        p {
          text "Let’s look at an example modal dialog in completely non-refactored (one-off) HTML:"
        }

        erb 'app/views/docs/copy_document.html.erb', <<-EOS
<div class="modal-background">
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
  <%= modal_form do %>
    <label for="document_name">Enter a new document name:</label>
    <input type="text" name="document_name">Copy of Untitled document</input>
    <span class="form-input-footnote">Comments will not be copied to the new document.</span>

    <input type="checkbox" name="copy_sharing"></input>
    <label for="copy_sharing">Share it with the same people</label>
  <% end %>
<% end %>
    <div class="modal-title">
      <h3 class="modal-title">Copy document</h3>
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

      def standard_engine_issues

      end

      def using_fortitude

      end

      def fortitude_benefits

      end
    end
  end
end
