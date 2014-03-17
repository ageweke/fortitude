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
        %w{time u ul var video wbr _text}

      # HTML5 spec, section 3.2.4.1.3
      SECTIONING_CONTENT = %w{article aside nav section}

      # HTML5 spec, section 3.2.4.1.4
      HEADING_CONTENT = %w{h1 h2 h3 h4 h5 h6}

      # HTML5 spec, section 3.2.4.1.5
      PHRASING_CONTENT = %w{a abbr area audio b bdi bdo br button canvas cite code data datalist del dfn em embed i} +
        %w{iframe img input ins kbd keygen label map mark math meter noscript object output progress q ruby s samp} +
        %w{script select small span strong sub sup svg template textarea time u var video wbr _text}

      # HTML5 spec, section 3.2.4.1.6
      EMBEDDED_CONTENT = %w{audio canvas embed iframe img math object svg video}

      # HTML5 spec, section 3.2.4.1.7
      INTERACTIVE_CONTENT = %w{a audio button details embed iframe img input keygen label object select textarea video}

      # HTML5 spec, section 3.2.4.1.8
      PALPABLE_CONTENT = %w{a abbr address article aside audio b bdi bdo blockquote button canvas cite code data} +
        %w{details dfn div dl em embed fieldset figure footer form h1 h2 h3 h4 h5 h6 header i iframe img input} +
        %w{ins kbd keygen label main map mark math meter nav object ol output p pre progress q ruby s samp section} +
        %w{select small span strong sub sup svg table textarea time u ul var video _text}

      # HTML5 spec, section 3.2.4.1.9
      SCRIPT_SUPPORTING_ELEMENTS = %w{script template}


      # ELEMENTS
      # ===============================================================================================================

      # HTML5 spec, section 4.1.1
      html5_tag :html, :newline_before => true, :can_enclose => %w{head body}, :valid_attributes => %w{manifest}

      # HTML5 spec, section 4.2
      html5_tag :head, :newline_before => true, :can_enclose => METADATA_CONTENT
      html5_tag :title, :newline_before => true, :can_enclose => %w{_text}
      html5_tag :base, :newline_before => true, :content_allowed => false, :valid_attributes => %w{href target}
      html5_tag :link, :newline_before => true, :content_allowed => false,
                       :valid_attributes => %w{href crossorigin rel media hreflang type sizes}
      html5_tag :meta, :newline_before => true, :content_allowed => false,
                       :valid_attributes => %w{name http-equiv content charset}
      html5_tag :style, :newline_before => true, :valid_attributes => %w{media type scoped}

      # HTML5 spec, section 4.3
      html5_tag :body, :newline_before => true, :can_enclose => FLOW_CONTENT,
                       :valid_attributes => %w{onafterprint onbeforeprint onbeforeunload onhashchange} +
                                            %w{onmessage onoffline ononline onpagehide onpageshow onpopstate} +
                                            %w{onstorage onunload}
      html5_tag :article, :newline_before => true, :can_enclose => FLOW_CONTENT
      html5_tag :section, :newline_before => true, :can_enclose => FLOW_CONTENT
      html5_tag :nav, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{main}
      html5_tag :aside, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{main}
      html5_tag :h1, :newline_before => true, :can_enclose => PHRASING_CONTENT
      html5_tag :h2, :newline_before => true, :can_enclose => PHRASING_CONTENT
      html5_tag :h3, :newline_before => true, :can_enclose => PHRASING_CONTENT
      html5_tag :h4, :newline_before => true, :can_enclose => PHRASING_CONTENT
      html5_tag :h5, :newline_before => true, :can_enclose => PHRASING_CONTENT
      html5_tag :h6, :newline_before => true, :can_enclose => PHRASING_CONTENT
      html5_tag :header, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{header footer main}
      html5_tag :footer, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{header footer main}
      html5_tag :address, :newline_before => true, :can_enclose => FLOW_CONTENT - HEADING_CONTENT - SECTIONING_CONTENT - %w{header footer address}

      # HTML5 spec, section 4.4
      html5_tag :p, :newline_before => true, :can_enclose => PHRASING_CONTENT
      html5_tag :hr, :newline_before => true, :content_allowed => false
      html5_tag :pre, :newline_before => true, :can_enclose => PHRASING_CONTENT
      html5_tag :blockquote, :newline_before => true, :can_enclose => FLOW_CONTENT, :valid_attributes => %w{cite}
      html5_tag :ol, :newline_before => true, :can_enclose => %w{li} + SCRIPT_SUPPORTING_ELEMENTS,
                     :valid_attributes => %w{reversed start type}
      html5_tag :ul, :newline_before => true, :can_enclose => %w{li} + SCRIPT_SUPPORTING_ELEMENTS
      html5_tag :li, :newline_before => true, :can_enclose => FLOW_CONTENT, :valid_attributes => %w{value}
      html5_tag :dl, :newline_before => true, :can_enclose => %w{dt dd} + SCRIPT_SUPPORTING_ELEMENTS
      html5_tag :dt, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{header footer} - SECTIONING_CONTENT - HEADING_CONTENT
      html5_tag :dd, :newline_before => true, :can_enclose => FLOW_CONTENT
      html5_tag :figure, :newline_before => true, :can_enclose => %w{figcaption} + FLOW_CONTENT
      html5_tag :figcaption, :newline_before => true, :can_enclose => FLOW_CONTENT
      html5_tag :div, :newline_before => true, :can_enclose => FLOW_CONTENT
      html5_tag :main, :newline_before => true, :can_enclose => FLOW_CONTENT

      # HTML5 spec, section 4.5
      html5_tag :a, :valid_attributes => %w{href target download rel hreflang type}
      html5_tag :em, :can_enclose => PHRASING_CONTENT
      html5_tag :strong, :can_enclose => PHRASING_CONTENT
      html5_tag :small, :can_enclose => PHRASING_CONTENT
      html5_tag :s, :can_enclose => PHRASING_CONTENT
      html5_tag :cite, :can_enclose => PHRASING_CONTENT
      html5_tag :q, :can_enclose => PHRASING_CONTENT, :valid_attributes => %w{cite}
      html5_tag :dfn, :can_enclose => PHRASING_CONTENT - %w{dfn}
      html5_tag :abbr, :can_enclose => PHRASING_CONTENT
      html5_tag :data, :can_enclose => PHRASING_CONTENT, :valid_attributes => %w{value}
      html5_tag :time, :can_enclose => PHRASING_CONTENT, :valid_attributes => %w{datetime}
      html5_tag :code, :can_enclose => PHRASING_CONTENT
      html5_tag :var, :can_enclose => PHRASING_CONTENT
      html5_tag :samp, :can_enclose => PHRASING_CONTENT
      html5_tag :kbd, :can_enclose => PHRASING_CONTENT
      html5_tag :sub, :can_enclose => PHRASING_CONTENT
      html5_tag :sup, :can_enclose => PHRASING_CONTENT
      html5_tag :i, :can_enclose => PHRASING_CONTENT
      html5_tag :b, :can_enclose => PHRASING_CONTENT
      html5_tag :u, :can_enclose => PHRASING_CONTENT
      html5_tag :mark, :can_enclose => PHRASING_CONTENT
      html5_tag :ruby, :can_enclose => PHRASING_CONTENT + %w{rb rt rtc rp}
      html5_tag :rb, :can_enclose => PHRASING_CONTENT
      html5_tag :rt, :can_enclose => PHRASING_CONTENT
      html5_tag :rtc, :can_enclose => PHRASING_CONTENT
      html5_tag :rp, :can_enclose => PHRASING_CONTENT
      html5_tag :bdi, :can_enclose => PHRASING_CONTENT
      html5_tag :bdo, :can_enclose => PHRASING_CONTENT
      html5_tag :span, :can_enclose => PHRASING_CONTENT
      html5_tag :br, :newline_before => true, :content_allowed => false
      html5_tag :wbr, :content_allowed => false






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
