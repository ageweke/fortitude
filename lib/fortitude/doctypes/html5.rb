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
      html5_tag :html, :newline_before => true, :can_enclose => %w{head body}, :valid_attributes => %w{manifest},
        :spec => 'http://www.w3.org/TR/html5/semantics.html#the-html-element'

      # HTML5 spec, section 4.2
      html5_tag :head, :newline_before => true, :can_enclose => METADATA_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/document-metadata.html#the-head-element'
      html5_tag :title, :newline_before => true, :can_enclose => %w{_text},
        :spec => 'http://www.w3.org/TR/html5/document-metadata.html#the-title-element'
      html5_tag :base, :newline_before => true, :content_allowed => false, :valid_attributes => %w{href target},
        :spec => 'http://www.w3.org/TR/html5/document-metadata.html#the-base-element'
      html5_tag :link, :newline_before => true, :content_allowed => false,
        :valid_attributes => %w{href crossorigin rel media hreflang type sizes},
        :spec => 'http://www.w3.org/TR/html5/document-metadata.html#the-link-element'
      html5_tag :meta, :newline_before => true, :content_allowed => false,
        :valid_attributes => %w{name http-equiv content charset},
        :spec => 'http://www.w3.org/TR/html5/document-metadata.html#the-meta-element'
      html5_tag :style, :newline_before => true, :valid_attributes => %w{media type scoped},
        :spec => 'http://www.w3.org/TR/html5/document-metadata.html#the-style-element'

      # HTML5 spec, section 4.3
      html5_tag :body, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :valid_attributes => %w{onafterprint onbeforeprint onbeforeunload onhashchange} +
                             %w{onmessage onoffline ononline onpagehide onpageshow onpopstate} +
                             %w{onstorage onunload},
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-body-element'
      html5_tag :article, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-article-element'
      html5_tag :section, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-section-element'
      html5_tag :nav, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{main},
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-nav-element'
      html5_tag :aside, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{main},
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-aside-element'
      html5_tag :h1, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements'
      html5_tag :h2, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements'
      html5_tag :h3, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements'
      html5_tag :h4, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements'
      html5_tag :h5, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements'
      html5_tag :h6, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements'
      html5_tag :header, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{header footer main},
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-header-element'
      html5_tag :footer, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{header footer main},
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-footer-element'
      html5_tag :address, :newline_before => true,
        :can_enclose => FLOW_CONTENT - HEADING_CONTENT - SECTIONING_CONTENT - %w{header footer address},
        :spec => 'http://www.w3.org/TR/html5/sections.html#the-address-element'

      # HTML5 spec, section 4.4
      html5_tag :p, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-p-element'
      html5_tag :hr, :newline_before => true, :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-hr-element'
      html5_tag :pre, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-pre-element'
      html5_tag :blockquote, :newline_before => true, :can_enclose => FLOW_CONTENT, :valid_attributes => %w{cite},
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-blockquote-element'
      html5_tag :ol, :newline_before => true, :can_enclose => %w{li} + SCRIPT_SUPPORTING_ELEMENTS,
        :valid_attributes => %w{reversed start type},
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-ol-element'
      html5_tag :ul, :newline_before => true, :can_enclose => %w{li} + SCRIPT_SUPPORTING_ELEMENTS,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-ul-element'
      html5_tag :li, :newline_before => true, :can_enclose => FLOW_CONTENT, :valid_attributes => %w{value},
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-li-element'
      html5_tag :dl, :newline_before => true, :can_enclose => %w{dt dd} + SCRIPT_SUPPORTING_ELEMENTS,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-dl-element'
      html5_tag :dt, :newline_before => true,
        :can_enclose => FLOW_CONTENT - %w{header footer} - SECTIONING_CONTENT - HEADING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-dt-element'
      html5_tag :dd, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-dd-element'
      html5_tag :figure, :newline_before => true, :can_enclose => %w{figcaption} + FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-figure-element'
      html5_tag :figcaption, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-figcaption-element'
      html5_tag :div, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-div-element'
      html5_tag :main, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/grouping-content.html#the-main-element'

      # HTML5 spec, section 4.5
      html5_tag :a, :valid_attributes => %w{href target download rel hreflang type},
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-a-element'
      html5_tag :em, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-em-element'
      html5_tag :strong, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-strong-element'
      html5_tag :small, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-small-element'
      html5_tag :s, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-s-element'
      html5_tag :cite, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-cite-element'
      html5_tag :q, :can_enclose => PHRASING_CONTENT, :valid_attributes => %w{cite},
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-q-element'
      html5_tag :dfn, :can_enclose => PHRASING_CONTENT - %w{dfn},
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-dfn-element'
      html5_tag :abbr, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-abbr-element'
      html5_tag :data, :can_enclose => PHRASING_CONTENT, :valid_attributes => %w{value},
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-data-element'
      html5_tag :time, :can_enclose => PHRASING_CONTENT, :valid_attributes => %w{datetime},
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-time-element'
      html5_tag :code, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-code-element'
      html5_tag :var, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-var-element'
      html5_tag :samp, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-samp-element'
      html5_tag :kbd, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-kbd-element'
      html5_tag :sub, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-sub-and-sup-elements'
      html5_tag :sup, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-sub-and-sup-elements'
      html5_tag :i, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-i-element'
      html5_tag :b, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-b-element'
      html5_tag :u, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-b-element'
      html5_tag :mark, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-mark-element'
      html5_tag :ruby, :can_enclose => PHRASING_CONTENT + %w{rb rt rtc rp},
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-ruby-element'
      html5_tag :rb, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-rb-element'
      html5_tag :rt, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-rt-element'
      html5_tag :rtc, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-rtc-element'
      html5_tag :rp, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-rp-element'
      html5_tag :bdi, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-bdi-element'
      html5_tag :bdo, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-bdo-element'
      html5_tag :span, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-span-element'
      html5_tag :br, :newline_before => true, :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-br-element'
      html5_tag :wbr, :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html5/text-level-semantics.html#the-wbr-element'

      # HTML5 spec, section 4.6
      html5_tag :ins, :valid_attributes => %w{cite datetime}, :spec => 'http://www.w3.org/TR/html5/edits.html#the-ins-element'
      html5_tag :del, :valid_attributes => %w{cite datetime}, :spec => 'http://www.w3.org/TR/html5/edits.html#the-del-element'

      # HTML5 spec, section 4.7
      html5_tag :img, :valid_attributes => %w{alt src crossorigin usemap ismap width height},
        :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-img-element'
      html5_tag :iframe, :newline_before => true, :valid_attributes => %w{src srcdoc name sandbox seamless width height},
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-iframe-element'
      html5_tag :embed, :newline_before => true, :valid_attributes => %w{src type width height}, :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-embed-element'
      html5_tag :object, :newline_before => true,
        :valid_attributes => %w{data type typemustmatch name usemap form width height},
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-object-element'
      html5_tag :param, :newline_before => true, :valid_attributes => %w{name value}, :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-param-element'
      html5_tag :video, :newline_before => true,
        :valid_attributes => %w{src crossorigin poster preload autoplay mediagroup loop muted controls width height},
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-video-element'
      html5_tag :audio, :newline_before => true,
        :valid_attributes => %w{src crossorigin preload autoplay mediagroup loop muted controls},
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-audio-element'
      html5_tag :source, :newline_before => true, :valid_attributes => %w{src type media}, :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-source-element'
      html5_tag :track, :newline_before => true, :valid_attributes => %w{kind src srclang label default},
        :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-track-element'
      html5_tag :map, :newline_before => true, :valid_attributes => %w{name},
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-map-element'
      html5_tag :area, :newline_before => true,
        :valid_attributes => %w{alt coords shape href target download rel hreflang type}, :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html5/embedded-content-0.html#the-area-element'

      # HTML5 spec, section 4.9
      html5_tag :table, :newline_before => true,
        :can_enclose => %w{caption colgroup thead tfoot tbody tr} + SCRIPT_SUPPORTING_ELEMENTS,
        :spec => 'http://www.w3.org/TR/html5/tabular-data.html#the-table-element'
      html5_tag :caption, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{table},
        :spec => 'http://www.w3.org/TR/html5/tabular-data.html#the-caption-element'
      html5_tag :colgroup, :newline_before => true, :valid_attributes => %w{span}, :can_enclose => %w{col template},
        :spec => 'http://www.w3.org/TR/html5/tabular-data.html#the-colgroup-element'
      html5_tag :col, :newline_before => true, :valid_attributes => %w{span}, :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html5/tabular-data.html#the-col-element'
      html5_tag :tbody, :newline_before => true, :can_enclose => %w{tr} + SCRIPT_SUPPORTING_ELEMENTS,
        :spec => 'http://www.w3.org/TR/html5/tabular-data.html#the-tbody-element'
      html5_tag :thead, :newline_before => true, :can_enclose => %w{tr} + SCRIPT_SUPPORTING_ELEMENTS,
        :spec => 'http://www.w3.org/TR/html5/tabular-data.html#the-thead-element'
      html5_tag :tfoot, :newline_before => true, :can_enclose => %w{tr} + SCRIPT_SUPPORTING_ELEMENTS,
        :spec => 'http://www.w3.org/TR/html5/tabular-data.html#the-tfoot-element'
      html5_tag :tr, :newline_before => true, :can_enclose => %w{td th} + SCRIPT_SUPPORTING_ELEMENTS,
        :spec => 'http://www.w3.org/TR/html5/tabular-data.html#the-tr-element'
      html5_tag :td, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :valid_attributes => %w{colspan rowspan headers},
        :spec => 'http://www.w3.org/TR/html5/tabular-data.html#the-td-element'
      html5_tag :th, :newline_before => true,
        :can_enclose => FLOW_CONTENT - %w{header footer} - SECTIONING_CONTENT - HEADING_CONTENT,
        :valid_attributes => %w{colspan rowspan headers scope abbr},
        :spec => 'http://www.w3.org/TR/html5/tabular-data.html#the-th-element'

      # HTML5 spec, section 4.10
      html5_tag :form, :newline_before => true, :can_enclose => FLOW_CONTENT - %w{form},
        :valid_attributes => %w{accept-charset action autocomplete enctype method name novalidate target},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-form-element'
      html5_tag :label, :newline_before => true,
        :can_enclose => PHRASING_CONTENT - %w{button keygen meter output progress select textarea} - %w{label},
        :valid_attributes => %w{form for},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-label-element'
      html5_tag :input, :newline_before => true, :content_allowed => false,
        :valid_attributes => %w{accept alt autocomplete autofocus checked dirname disabled form formaction} +
                             %w{formenctype formmethod formnovalidate formtarget height list max maxlength} +
                             %w{min minlength multiple name pattern placeholder readonly required size src} +
                             %w{step type value width},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-input-element'
      html5_tag :button, :newline_before => true, :can_enclose => PHRASING_CONTENT - INTERACTIVE_CONTENT,
        :valid_attributes => %w{autofocus disabled form formaction formenctype formmethod formnovalidate} +
                             %w{formtarget name type value},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-button-element'
      html5_tag :select, :newline_before => true, :can_enclose => %w{option optgroup} + SCRIPT_SUPPORTING_ELEMENTS,
        :valid_attributes => %w{autofocus disabled form multiple name required size},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-select-element'
      html5_tag :datalist, :newline_before => true, :can_enclose => PHRASING_CONTENT + %w{option},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-datalist-element'
      html5_tag :optgroup, :newline_before => true, :can_enclose => %w{option} + SCRIPT_SUPPORTING_ELEMENTS,
        :valid_attributes => %w{disabled label},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-optgroup-element'
      html5_tag :option, :newline_before => true, :can_enclose => %w{_text},
        :valid_attributes => %w{disabled label selected value},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-option-element'
      html5_tag :textarea, :newline_before => true, :can_enclose => %w{_text},
        :valid_attributes => %w{autocomplete autofocus cols dirname disabled form maxlength minlength name} +
                             %w{placeholder readonly required rows wrap},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-textarea-element'
      html5_tag :keygen, :newline_before => true, :content_allowed => false,
        :valid_attributes => %w{autofocus challenge disabled form keytype name},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-keygen-element'
      html5_tag :output, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :valid_attributes => %w{for form name},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-output-element'
      html5_tag :progress, :newline_before => true, :can_enclose => PHRASING_CONTENT - %w{progress},
        :valid_attributes => %w{value max},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-progress-element'
      html5_tag :meter, :newline_before => true, :can_enclose => PHRASING_CONTENT - %w{meter},
        :valid_attributes => %w{value min max low high optimum},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-meter-element'
      html5_tag :fieldset, :newline_before => true, :can_enclose => FLOW_CONTENT + %w{legend},
        :valid_attributes => %w{disabled form name},
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-fieldset-element'
      html5_tag :legend, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/forms.html#the-legend-element'

      # HTML5 spec, section 4.11
      html5_tag :details, :newline_before => true, :can_enclose => %w{summary} + FLOW_CONTENT,
        :valid_attributes => %w{open},
        :spec => 'http://www.w3.org/TR/html5/interactive-elements.html#the-details-element'
      html5_tag :summary, :newline_before => true, :can_enclose => PHRASING_CONTENT,
        :spec => 'http://www.w3.org/TR/html5/interactive-elements.html#the-summary-element'
      html5_tag :dialog, :newline_before => true, :can_enclose => FLOW_CONTENT, :valid_attributes => %w{open},
        :spec => 'http://www.w3.org/TR/html5/interactive-elements.html#the-dialog-element'

      # HTML5 spec, section 4.12
      html5_tag :script, :newline_before => true, :can_enclose => %w{_text},
        :valid_attributes => %w{src type charset async defer crossorigin},
        :spec => 'http://www.w3.org/TR/html5/scripting-1.html#the-script-element'
      html5_tag :noscript, :newline_before => true,
        :spec => 'http://www.w3.org/TR/html5/scripting-1.html#the-noscript-element'
      html5_tag :template, :newline_before => true,
        :spec => 'http://www.w3.org/TR/html5/scripting-1.html#the-template-element'
      html5_tag :canvas, :newline_before => true, :valid_attributes => %w{width height},
        :spec => 'http://www.w3.org/TR/html5/scripting-1.html#the-canvas-element'
    end
  end
end
