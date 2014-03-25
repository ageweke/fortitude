require 'fortitude/doctypes/base'

module Fortitude
  module Doctypes
    class Html4 < Base
      def default_javascript_tag_attributes
        { :type => 'text/javascript'.freeze }.freeze
      end

      def needs_cdata_in_javascript_tag?
        false
      end

      # HTML4.01 DTD
      I18N_ATTRIBUTES = %w{lang dir}
      CORE_ATTRIBUTES = %w{id class style title}
      EVENTS_ATTRIBUTES = %w{onclick ondblclick onmousedown onmouseup onmouseover onmousemove onmouseout onkeypress onkeydown onkeyup}
      ATTRS_ATTRIBUTES = CORE_ATTRIBUTES + I18N_ATTRIBUTES + EVENTS_ATTRIBUTES

      CELLHALIGN_ATTRIBUTES = %w{align char charoff}
      CELLVALIGN_ATTRIBUTES = %w{valign}

      HEADING_CONTENT = %w{h1 h2 h3 h4 h5 h6}
      LIST_CONTENT = %w{ul ol}
      PREFORMATTED_CONTENT = %w{pre}
      BLOCK_CONTENT = %w{p} + HEADING_CONTENT + LIST_CONTENT + PREFORMATTED_CONTENT + %w{dl div noscript} +
                      %w{blockquote form hr table fieldset address}
      FONTSTYLE_CONTENT = %w{tt i b big small}
      PHRASE_CONTENT = %w{em strong dfn code samp kbd var cite abbr acronym}
      SPECIAL_CONTENT = %w{a img object br script map q sub sup span bdo}
      FORMCTRL_CONTENT = %w{input select textarea label button}
      INLINE_CONTENT = %w{_text} + FONTSTYLE_CONTENT + PHRASE_CONTENT + SPECIAL_CONTENT + FORMCTRL_CONTENT
      FLOW_CONTENT = BLOCK_CONTENT + INLINE_CONTENT

      # HTML4.01 spec, section 7.3
      tag :html, :newline_before => true, :valid_attributes => I18N_ATTRIBUTES + %w{version},
        :can_enclose => %w{head body},
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.3'

      # HTML4.01 spec, section 7.4
      tag :head, :newline_before => true, :valid_attributes => I18N_ATTRIBUTES + %w{profile},
        :can_enclose => %w{script style meta link object title base},
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.4.1'
      tag :title, :newline_before => true, :valid_attributes => I18N_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.4.2'
      tag :meta, :newline_before => true, :valid_attributes => I18N_ATTRIBUTES + %w{http-equiv name content scheme},
        :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.4.4.2'

      # HTML4.01 spec, section 7.5
      tag :body, :newline_before => true, :valid_attributes => I18N_ATTRIBUTES + CORE_ATTRIBUTES + EVENTS_ATTRIBUTES,
        :can_enclose => BLOCK_CONTENT + %w{script ins del},
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.1'
      tag :div, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.4'
      tag :span, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.4'
      tag :h1, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.5'
      tag :h2, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.5'
      tag :h3, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.5'
      tag :h4, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.5'
      tag :h5, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.5'
      tag :h6, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.5'
      tag :address, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.6'

      # HTML4.01 spec, section 9.2
      tag :em, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.1'
      tag :strong, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.1'
      tag :dfn, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.1'
      tag :code, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.1'
      tag :samp, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.1'
      tag :kbd, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.1'
      tag :var, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.1'
      tag :cite, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.1'
      tag :abbr, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.1'
      tag :acronym, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.1'
      tag :blockquote, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES + %w{cite},
        :can_enclose => BLOCK_CONTENT + %w{script},
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.2'
      tag :q, :valid_attributes => ATTRS_ATTRIBUTES + %w{cite}, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.2'
      tag :sub, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.3'
      tag :sup, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.2.3'

      # HTML4.01 spec, section 9.3
      tag :p, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.3.1'
      tag :br, :newline_before => true, :valid_attributes => CORE_ATTRIBUTES, :content_allowed => false,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.3.2.1'
      tag :pre, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES,
        :can_enclose => INLINE_CONTENT - %w{img object big small sub sup},
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.3.4'
      tag :ins, :valid_attributes => ATTRS_ATTRIBUTES + %w{cite datetime}, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.4'
      tag :del, :valid_attributes => ATTRS_ATTRIBUTES + %w{cite datetime}, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/text.html#h-9.4'

      # HTML4.01 spec, section 10.2
      tag :ul, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => %w{li},
        :spec => 'http://www.w3.org/TR/html401/struct/lists.html#h-10.2'
      tag :ol, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => %w{li},
        :spec => 'http://www.w3.org/TR/html401/struct/lists.html#h-10.2'
      tag :li, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/lists.html#h-10.2'
      tag :dl, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => %w{dt dd},
        :spec => 'http://www.w3.org/TR/html401/struct/lists.html#h-10.3'
      tag :dt, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => INLINE_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/lists.html#h-10.3'
      tag :dd, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/lists.html#h-10.3'
      # TODO: DEPRECATED?
      tag :dir, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES + %w{compact},
        :can_enclose => %w{li},
        :spec => 'http://www.w3.org/TR/html401/sgml/loosedtd.html#dir'
      # TODO: DEPRECATED?
      tag :menu, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES + %w{menu},
        :can_enclose => %w{li},
        :spec => 'http://www.w3.org/TR/html401/sgml/loosedtd.html#dir'

      # HTML4.01 spec, section 11.2
      tag :table, :newline_before => true, :can_enclose => %w{caption col colgroup thead tfoot tbody tr},
        :valid_attributes => ATTRS_ATTRIBUTES + %w{summary width border frame rules cellspacing cellpadding},
        :spec => 'http://www.w3.org/TR/html401/struct/tables.html#h-11.2.1'
      tag :caption, :newline_before => true, :can_enclose => INLINE_CONTENT, :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/struct/tables.html#h-11.2.2'
      tag :thead, :newline_before => true, :can_enclose => %w{tr},
        :valid_attributes => ATTRS_ATTRIBUTES + CELLVALIGN_ATTRIBUTES + CELLVALIGN_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/struct/tables.html#h-11.2.3'
      tag :tfoot, :newline_before => true, :can_enclose => %w{tr},
        :valid_attributes => ATTRS_ATTRIBUTES + CELLVALIGN_ATTRIBUTES + CELLVALIGN_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/struct/tables.html#h-11.2.3'
      tag :tbody, :newline_before => true, :can_enclose => %w{tr},
        :valid_attributes => ATTRS_ATTRIBUTES + CELLVALIGN_ATTRIBUTES + CELLVALIGN_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/struct/tables.html#h-11.2.3'
      tag :colgroup, :newline_before => true, :can_enclose => %w{col},
        :valid_attributes => ATTRS_ATTRIBUTES + %w{span width} + CELLHALIGN_ATTRIBUTES + CELLVALIGN_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/struct/tables.html#h-11.2.4.1'
      tag :col, :newline_before => true, :content_allowed => false,
        :valid_attributes => ATTRS_ATTRIBUTES + %w{span width} + CELLHALIGN_ATTRIBUTES + CELLVALIGN_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/struct/tables.html#h-11.2.4.2'
      tag :tr, :newline_before => true, :can_enclose => %w{th td},
        :valid_attributes => ATTRS_ATTRIBUTES + CELLHALIGN_ATTRIBUTES + CELLVALIGN_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/struct/tables.html#h-11.2.5'
      tag :th, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :valid_attributes => ATTRS_ATTRIBUTES + %w{abbr axis headers scope rowspan colspan} + CELLHALIGN_ATTRIBUTES + CELLVALIGN_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/struct/tables.html#h-11.2.6'
      tag :td, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :valid_attributes => ATTRS_ATTRIBUTES + %w{abbr axis headers scope rowspan colspan} + CELLHALIGN_ATTRIBUTES + CELLVALIGN_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/struct/tables.html#h-11.2.6'

      # HTML4.01 spec, section 12.3
      tag :link, :newline_before => true, :content_allowed => false,
        :valid_attributes => ATTRS_ATTRIBUTES + %w{charset href hreflang type rel rev media},
        :spec => 'http://www.w3.org/TR/html401/struct/links.html#h-12.3'

      # HTML4.01 spec, section 12.4
      tag :base, :newline_before => true, :content_allowed => false, :valid_attributes => %w{href},
        :spec => 'http://www.w3.org/TR/html401/struct/links.html#h-12.4'

      # HTML4.01 spec, section 13.2
      tag :img, :content_allowed => false,
        :valid_attributes => ATTRS_ATTRIBUTES + %w{src alt longdesc name height width usemap ismap},
        :spec => 'http://www.w3.org/TR/html401/struct/objects.html#h-13.2'

      # HTML4.01 spec, section 13.3
      tag :object, :newline_before => true, :can_enclose => FLOW_CONTENT + %w{param},
        :valid_attributes => ATTRS_ATTRIBUTES + %w{declare classid codebase data type codetype archive standby height} +
                             %w{width usemap name tabindex},
        :spec => 'http://www.w3.org/TR/html401/struct/objects.html#h-13.3'
      tag :param, :newline_before => true, :content_allowed => false,
        :valid_attributes => %w{id name value valuetype type},
        :spec => 'http://www.w3.org/TR/html401/struct/objects.html#h-13.3.2'

      # HTML4.01 spec, section 13.4
      # TODO: DEPRECATED?
      tag :applet, :newline_before => true, :can_enclose => %w{param} + FLOW_CONTENT,
        :valid_attributes => CORE_ATTRIBUTES + %w{codebase archive code object alt name width height align hspace vspace},
        :spec => 'http://www.w3.org/TR/html401/struct/objects.html#h-13.4'

      # HTML4.01 spec, section 13.6
      tag :map, :newline_before => true, :can_enclose => BLOCK_CONTENT + %w{area},
        :valid_attributes => ATTRS_ATTRIBUTES + %w{name},
        :spec => 'http://www.w3.org/TR/html401/struct/objects.html#h-13.6.1'
      tag :area, :newline_before => true, :content_allowed => false,
        :valid_attributes => ATTRS_ATTRIBUTES + %w{shape coords href nohref alt tabindex accesskey onfocus onblur},
        :spec => 'http://www.w3.org/TR/html401/struct/objects.html#h-13.6.1'

      # HTML4.01 spec, section 15.2
      tag :tt, :can_enclose => INLINE_CONTENT, :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/graphics.html#h-15.2.1'
      tag :i, :can_enclose => INLINE_CONTENT, :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/graphics.html#h-15.2.1'
      tag :b, :can_enclose => INLINE_CONTENT, :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/graphics.html#h-15.2.1'
      tag :big, :can_enclose => INLINE_CONTENT, :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/graphics.html#h-15.2.1'
      tag :small, :can_enclose => INLINE_CONTENT, :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/graphics.html#h-15.2.1'
      tag :strike, :can_enclose => INLINE_CONTENT, :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/graphics.html#h-15.2.1'
      tag :s, :can_enclose => INLINE_CONTENT, :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/graphics.html#h-15.2.1'
      tag :u, :can_enclose => INLINE_CONTENT, :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/graphics.html#h-15.2.1'
      tag :font, :can_enclose => INLINE_CONTENT,
        :valid_attributes => CORE_ATTRIBUTES + I18N_ATTRIBUTES + %w{size color face},
        :spec => 'http://www.w3.org/TR/html401/sgml/loosedtd.html#basefont'
      tag :basefont, :content_allowed => false, :valid_attributes => %w{id size color face},
        :spec => 'http://www.w3.org/TR/html401/sgml/loosedtd.html#basefont'

      # HTML4.01 spec, section 15.3
      tag :hr, :newline_before => true, :content_allowed => false, :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/graphics.html#h-15.3'

      # HTML4.01 spec, section 16.2
      # TODO: Frameset DTD?
      tag :frameset, :newline_before => true, :can_enclose => %w{frameset frame noframes},
        :valid_attributes => CORE_ATTRIBUTES + %w{rows cols onload onunload},
        :spec => 'http://www.w3.org/TR/html401/present/frames.html#h-16.2.1'
      tag :frame, :newline_before => true, :content_allowed => false,
        :valid_attributes => CORE_ATTRIBUTES + %w{longdesc name src frameborder marginwidth marginheight noresize scrolling},
        :spec => 'http://www.w3.org/TR/html401/present/frames.html#h-16.2.2'
      tag :noframes, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/frames.html#h-16.4.1'

      # HTML4.01 spec, section 16.5
      tag :iframe, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :valid_attributes => CORE_ATTRIBUTES + %w{longdesc name src frameborder marginwidth marginheight scrolling} +
                             %w{align height width},
        :spec => 'http://www.w3.org/TR/html401/present/frames.html#h-16.5'

      # HTML4.01 spec, section 17.3
      tag :form, :newline_before => true, :can_enclose => BLOCK_CONTENT + %w{script} - %w{form},
        :valid_attributes => ATTRS_ATTRIBUTES + %w{action method enctype accept name onsubmit onreset accept-charset},
        :spec => 'http://www.w3.org/TR/html401/interact/forms.html#h-17.3'

      # HTML4.01 spec, section 17.4
      tag :input, :newline_before => true, :content_allowed => false,
        :valid_attributes => ATTRS_ATTRIBUTES + %w{type name value checked disabled readonly size maxlength src alt} +
                             %w{usemap ismap tabindex accesskey onfocus onblur onselect onchange accept},
        :spec => 'http://www.w3.org/TR/html401/interact/forms.html#h-17.4'

      # HTML4.01 spec, section 17.5
      tag :button, :newline_before => true, :can_enclose => FLOW_CONTENT - FORMCTRL_CONTENT - %w{a form fieldset},
        :valid_attributes => ATTRS_ATTRIBUTES + %w{name value type disabled tabindex accesskey onfocus onblur},
        :spec => 'http://www.w3.org/TR/html401/interact/forms.html#h-17.5'

      # HTML4.01 spec, section 17.6
      tag :select, :newline_before => true, :can_enclose => %w{optgroup option},
        :valid_attributes => ATTRS_ATTRIBUTES + %w{name size multiple disabled tabindex onfocus onblur onchange},
        :spec => 'http://www.w3.org/TR/html401/interact/forms.html#h-17.6'
      tag :optgroup, :newline_before => true, :can_enclose => %w{option},
        :valid_attributes => ATTRS_ATTRIBUTES + %w{disabled label},
        :spec => 'http://www.w3.org/TR/html401/interact/forms.html#h-17.6'
      tag :option, :newline_before => true, :can_enclose => %w{_text},
        :valid_attributes => ATTRS_ATTRIBUTES + %w{selected disabled label value},
        :spec => 'http://www.w3.org/TR/html401/interact/forms.html#h-17.6'

      # HTML4.01 spec, section 17.7
      tag :textarea, :newline_before => true, :can_enclose => %w{_text},
        :valid_attributes => ATTRS_ATTRIBUTES + %w{name rows cols disabled readonly tabindex accesskey} +
                             %w{onfocus onblur onselect onchange},
        :spec => 'http://www.w3.org/TR/html401/interact/forms.html#h-17.7'
      # TODO: DEPRECATED?
      tag :isindex, :newline_before => true, :content_allowed => false,
        :valid_attributes => CORE_ATTRIBUTES + I18N_ATTRIBUTES + %w{prompt},
        :spec => 'http://www.w3.org/TR/html401/sgml/loosedtd.html#isindex'

      # HTML4.01 spec, section 17.9
      tag :label, :newline_before => true, :can_enclose => INLINE_CONTENT,
        :valid_attributes => ATTRS_ATTRIBUTES + %w{for accesskey onfocus onblur},
        :spec => 'http://www.w3.org/TR/html401/interact/forms.html#h-17.9.1'

      # HTML4.01 spec, section 17.10
      tag :fieldset, :newline_before => true, :can_enclose => %w{_text legend} + FLOW_CONTENT,
        :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/interact/forms.html#h-17.10'
      tag :legend, :newline_before => true, :can_enclose => INLINE_CONTENT,
        :valid_attributes => ATTRS_ATTRIBUTES + %w{accesskey},
        :spec => 'http://www.w3.org/TR/html401/interact/forms.html#h-17.10'

      # HTML4.01 spec, section 18.2
      tag :script, :newline_before => true, :can_enclose => %w{_text},
        :valid_attributes => %w{charset type src defer},
        :spec => 'http://www.w3.org/TR/html401/interact/scripts.html#h-18.2.1'
      # HTML4.01 spec, section 18.3
      tag :noscript, :newline_before => true, :can_enclose => BLOCK_CONTENT,
        :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/interact/scripts.html#h-18.3.1'
    end
  end
end
