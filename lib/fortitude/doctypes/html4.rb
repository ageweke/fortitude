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
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.4.4.2'

      # HTML4.01 spec, section 7.5
      tag :body, :newline_before => true, :valid_attributes => I18N_ATTRIBUTES + CORE_ATTRIBUTES + EVENTS_ATTRIBUTES,
        :can_enclose => BLOCK_CONTENT + %w{script ins del},
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.1'
      tag :div, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => FLOW_CONTENT,
        :spec => 'http://www.w3.org/TR/html401/struct/global.html#h-7.5.4'
    end
  end
end
