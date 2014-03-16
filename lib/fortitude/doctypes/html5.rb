require 'fortitude/doctypes/base'

module Fortitude
  module Doctypes
    class Html5 < Base
      def initialize
        super(:html5, "html")
      end

      def default_javascript_tag_attributes
        { }
      end

      def needs_cdata_in_javascript_tag?
        false
      end

      # HTML5 spec, section 3.2.5
      GLOBAL_ATTRIBUTES = %w{accesskey class contenteditable dir draggable dropzone hidden id lang spellcheck style} +
        %w{tabindex title translate}

      # HTML5 spec, section 3.2.7
      ARIA_ATTRIBUTES = %w{role}

      # HTML5 spec, section 3.2.5
      EVENT_HANDLER_GLOBAL_ATTRIBUTES = %w{onabort onblur oncancel oncanplay oncanplaythrough onchange onclick} +
        %w{onclose oncuechange ondblclick ondrag ondragend ondragenter ondragexit ondragleave ondragover ondragstart} +
        %w{ondrop ondurationchange onemptied onended onerror onfocus oninput oninvalid onkeydown onkeypress onkeyup} +
        %w{onload onloadeddata onloadedmetadata onloadstart onmousedown onmouseenter onmouseleave onmousemove} +
        %w{onmouseout onmouseover onmouseup onmousewheel onpause onplay onplaying onprogress onratechange onreset} +
        %w{onresize onscroll onseeked onseeking onselect onshow onstalled onsubmit onsuspend ontimeupdate ontoggle} +
        %w{onvolumechange onwaiting}

      ALL_ELEMENTS_ATTRIBUTES = GLOBAL_ATTRIBUTES | ARIA_ATTRIBUTES | EVENT_HANDLER_GLOBAL_ATTRIBUTES

      class << self
        def html5_tag(name, options = { })
          options[:valid_attributes] = (options[:valid_attributes] || [ ]).map { |x| x.to_s.strip.downcase }
          options[:valid_attributes] |= ALL_ELEMENTS_ATTRIBUTES

          tag(name, options)
        end
      end

      # HTML5 spec, section 3.2.4.1.1
      METADATA_CONTENT = %w{base link meta noscript script style template title}

      # HTML5 spec, section 3.2.4.1.2
      FLOW_CONTENT = %w{a abbr address area article aside audio b bdi bdo blockquote br button canvas cite code data} +
        %w{datalist del details dfn dialog div dl em embed fieldset figure footer form h1 h2 h3 h4 h5 h6 header hr i} +
        %w{iframe img input ins kbd keygen label main map mark math meter nav noscript object ol output p pre} +
        %w{progress q ruby s samp script section select small span strong style sub sup svg table template textarea} +
        %w{time u ul var video wbr text}

      # HTML5 spec, section 3.2.4.1.3
      SECTIONING_CONTENT = %w{article aside nav section}

      # HTML5 spec, section 3.2.4.1.4
      HEADING_CONTENT = %w{h1 h2 h3 h4 h5 h6}

      # HTML5 spec, section 3.2.4.1.5
      PHRASING_CONTENT = %w{a abbr area audio b bdi bdo br button canvas cite code data datalist del dfn em embed i} +
        %w{iframe img input ins kbd keygen label map mark math meter noscript object output progress q ruby s samp} +
        %w{script select small span strong sub sup svg template textarea time u var video wbr text}

      # HTML5 spec, section 3.2.4.1.6
      EMBEDDED_CONTENT = %w{audio canvas embed iframe img math object svg video}

      # HTML5 spec, section 3.2.4.1.7
      INTERACTIVE_CONTENT = %w{a audio button details embed iframe img input keygen label object select textarea video}

      # HTML5 spec, section 3.2.4.1.8
      PALPABLE_CONTENT = %w{a abbr address article aside audio b bdi bdo blockquote button canvas cite code data} +
        %w{details dfn div dl em embed fieldset figure footer form h1 h2 h3 h4 h5 h6 header i iframe img input} +
        %w{ins kbd keygen label main map mark math meter nav object ol output p pre progress q ruby s samp section} +
        %w{select small span strong sub sup svg table textarea time u ul var video text}

      # HTML5 spec, section 3.2.4.1.9
      SCRIPT_SUPPORTING_ELEMENTS = %w{script template}

      html5_tag :html, :newline_before => true
      html5_tag :body, :newline_before => true
      html5_tag :head, :newline_before => true
      html5_tag :link, :newline_before => true, :content_allowed => false
      html5_tag :style, :newline_before => true

      html5_tag :header, :newline_before => true
      html5_tag :nav, :newline_before => true
      html5_tag :section, :newline_before => true
      html5_tag :footer, :newline_before => true

      html5_tag :script, :newline_before => true
      html5_tag :meta, :newline_before => true, :content_allowed => false
      html5_tag :title, :newline_before => true

      html5_tag :h1, :newline_before => true
      html5_tag :h2, :newline_before => true
      html5_tag :h3, :newline_before => true
      html5_tag :h4, :newline_before => true
      html5_tag :h5, :newline_before => true
      html5_tag :h6, :newline_before => true

      html5_tag :div, :newline_before => true
      html5_tag :span

      html5_tag :ul, :newline_before => true
      html5_tag :ol, :newline_before => true
      html5_tag :li, :newline_before => true

      html5_tag :p, :newline_before => true, :can_enclose => [ :b ], :valid_attributes => %w{class id}

      html5_tag :a
      html5_tag :img

      html5_tag :form, :newline_before => true
      html5_tag :input, :newline_before => true
      html5_tag :submit, :newline_before => true
      html5_tag :button, :newline_before => true
      html5_tag :label, :newline_before => true
      html5_tag :select, :newline_before => true
      html5_tag :optgroup, :newline_before => true
      html5_tag :option, :newline_before => true
      html5_tag :textarea, :newline_before => true
      html5_tag :fieldset, :newline_before => true

      html5_tag :table, :newline_before => true
      html5_tag :tr, :newline_before => true
      html5_tag :th, :newline_before => true
      html5_tag :td, :newline_before => true

      html5_tag :time

      html5_tag :i
      html5_tag :b
      html5_tag :em
      html5_tag :strong

      html5_tag :br, :content_allowed => false
      html5_tag :hr, :newline_before => true, :content_allowed => false
    end
  end
end
