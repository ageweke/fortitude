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

    end
  end
end
