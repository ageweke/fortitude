require 'source/why/example_page'

module Views
  module Why
    class WritingCorrectHtml < Views::Why::ExamplePage
      def example_content
        h4 "Invalid HTML, Part 1"
        nesting_example

        h4 "Invalid HTML, Part 2"
        attribute_example

        h4 "Invalid HTML, Part 3"
        id_example

        h4 "Configuration"
        qualification

        h4 "A Bonus"
        self_closing_example

        closing
      end

      def nesting_example
        p {
          text "Quick — what’s wrong with the following code?"
        }

        erb '/app/views/example/test1.html.erb', <<-EOS
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
          text "Write it as Fortitude, and it knows right away:"
        }

        pre %{
Fortitude::Errors::InvalidElementNesting at /app/views/example/test1.html.rb:17
The widget #<Views::Example::Test1:0x007fcf7a337da8> tried to
render an element that is not allowed by element nesting rules:
you can't put a <div> inside a <p>.
(See 'http://www.w3.org/TR/html5/grouping-content.html#the-p-element'
for more details.)
}
      end

      def attribute_example
        p {
          text "And, quick — what’s wrong with "; em "this"; text " code?"
        }

        erb '/app/views/example/test2.html.erb', <<-EOS
<div class="main-content">
  <div class="introduction">
    <h1>Rock 'N Roll</h1>
    <p class="body">What we call today "rock 'n roll" really started with the blues. Listen to this:</p>
    <audio src="http://example.com/mp3/blues1.mp3" preload="true" width="600" autoplay="false">
  </div>
</div>
EOS

        p {
          text "Once again, Fortitude knows:"
        }

        pre %{
Fortitude::Errors::InvalidElementAttributes at /app/views/example/test2.html.rb:11
The widget #<Views::Example::Test2:0x007fcf830a8548> tried to
render an element, <audio>, with attributes that are
not allowed: {:width=>400}.
Only these attributes are allowed: [:accesskey, :autoplay,
  :class, :contenteditable, :controls, :crossorigin, :dir,
  :draggable, :dropzone, :hidden, :id, :lang, :loop,
  :mediagroup, :muted, :onabort, :onblur, :oncancel,
  :oncanplay, :oncanplaythrough, :onchange, :onclick,
  :onclose, :oncuechange, :ondblclick, :ondrag, :ondragend,
  :ondragenter, :ondragexit, :ondragleave, :ondragover,
  :ondragstart, :ondrop, :ondurationchange, :onemptied,
  :onended, :onerror, :onfocus, :oninput, :oninvalid,
  :onkeydown, :onkeypress, :onkeyup, :onload,
  :onloadeddata, :onloadedmetadata, :onloadstart,
  :onmousedown, :onmouseenter, :onmouseleave, :onmousemove,
  :onmouseout, :onmouseover, :onmouseup, :onmousewheel,
  :onpause, :onplay, :onplaying, :onprogress, :onratechange,
  :onreset, :onresize, :onscroll, :onseeked, :onseeking,
  :onselect, :onshow, :onstalled, :onsubmit, :onsuspend,
  :ontimeupdate, :ontoggle, :onvolumechange, :onwaiting,
  :preload, :role, :spellcheck, :src, :style, :tabindex,
  :title, :translate]
  (See 'http://www.w3.org/TR/html5/embedded-content-0.html#the-audio-element'
for more details.)}
      end

      def id_example
        p {
          text "And, finally, what’s wrong with this code?"
        }

        erb '/app/views/example/test3.html.erb', <<-EOS
<div class="main-content">
  <div class="introduction">
    <h3>Introduction</h3>
    <p class="body" id="para">In the <em>very</em>beginning, the Web was nothing but <span class="highlighted">completely static</span>
       content. While static content was in many ways <div class="extra_emphasis">amazing</div> for the time,
       just because of the ease of use, it was not enough.</p>
    <p class="body" id="para">And so this begat the CGI. Someone realized that <strong>any program at all</strong> could generate
       HTML, and that was also <span class="highlighted">amazing</span>.</p>
  </div>
</div>
EOS

        p {
          text "You guessed it — Fortitude knows:"
        }

        pre %{
Fortitude::Errors::DuplicateId at /app/views/example/test3.html.rb:17
The widget #<Views::Example::Test3:0x007fcf7ae3ed00> tried to use
a DOM ID, 'para', that has already been used. It was originally
used on a <p> tag within widget #<Views::Example::Test3:0x007fcf7ae3ed00>,
and is now trying to be used on a <p> tag.}

        vertical_space

        p {
          text "Fortitude’s ID checking operates "; em "across the entire page"; text ", and is fully dynamic — "
          text "if you re-use an ID that’s been used in any view or partial, anywhere on that page, you’ll get a "
          text "precise error, telling you exactly what’s wrong."
        }
      end

      def qualification
        p {
          strong "Every single one of these features is configurable. "
          text "In particular, they’re off by default, and we recommend you only turn them on "
          text "in development mode. (In production, it’s almost always better to emit invalid HTML "
          text "than to show your user a 500 page.)"
        }

        p {
          text "Use these features from the beginning of your Fortitude development, and a huge amount "
          text "of checking with an HTML validator (or just emitting invalid markup) simply vanishes."
        }
      end

      def self_closing_example
        p {
          text "And, as an added bonus: what’s wrong with this code?"
        }

        html_source <<-EOS
<p>We’ll use CSS to add some space
at this empty span: <span class="spacer" />. See?<br />
Wasn’t that nice?</p>
EOS

        p {
          text "This code almost certainly "
          a("does not mean what the author thought it meant", :href => 'http://tiffanybbrown.com/2011/03/23/html5-does-not-allow-self-closing-tags/')
          text ": you "; strong "cannot close a "; code "<span>"; text " or other such elements using ";
          code "/>"; text " in HTML, and void tags like "; code "<br>"; text " should never be written using "
          code "/>"; text ". (And, lest you think this is a theoretical problem only, take a look at the "
          text "linked article — older browsers can and will render your page differently if you do this.)"
        }

        p {
          text "On the other hand, this Fortitude code:"
        }

        fortitude <<-EOS
p {
  text "We’ll use CSS to add some space at this empty span: "
  span :class => 'spacer'
  text ". See?"
  br
  text "Wasn’t that nice?"
}
EOS

        p {
          text "…will render as this correct HTML — with Fortitude, it is impossible to make these kinds "
          text "of mistakes:"
        }

        html_source <<-EOS
<p>We’ll use CSS to add some space
at this empty span: <span class="spacer"></span>. See?<br>
Wasn’t that nice?</p>
EOS
      end

      def closing
        p {
          text "In our next example, we’ll see how Fortitude’s formatting and commenting features make it a whole "
          text "lot easier to read the resulting HTML and discover which view is responsible for emitting a particular "
          text "piece of HTML."
        }
      end
    end
  end
end
