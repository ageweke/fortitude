require 'fortitude/tag_store'
require 'fortitude/doctypes/html4_tags_strict'

module Fortitude
  module Doctypes
    module Html4TagsTransitional
      extend Fortitude::TagStore

      class << self
        def delegate_tag_stores
          [ Fortitude::Doctypes::Html4TagsStrict ]
        end
      end

      TRANSITIONAL_BLOCK_CONTENT = %w{dir menu center isindex}
      TRANSITIONAL_INLINE_CONTENT = %w{u s strike applet font basefont iframe}
      TRANSITIONAL_FLOW_CONTENT = %w{dir menu center isindex u s strike applet font basefont iframe}

      %w{ATTRS_ATTRIBUTES FLOW_CONTENT INLINE_CONTENT CORE_ATTRIBUTES I18N_ATTRIBUTES}.each do |constant_name|
        const_set(constant_name, Fortitude::Doctypes::Html4TagsStrict.const_get(constant_name))
      end

      tag :dir, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES + %w{compact},
        :can_enclose => %w{li},
        :spec => 'http://www.w3.org/TR/html401/sgml/loosedtd.html#dir'
      tag :menu, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES + %w{menu},
        :can_enclose => %w{li},
        :spec => 'http://www.w3.org/TR/html401/sgml/loosedtd.html#dir'

      tag :center, :valid_attributes => ATTRS_ATTRIBUTES, :can_enclose => FLOW_CONTENT

      # HTML4.01 spec, section 13.4
      tag :applet, :newline_before => true, :can_enclose => %w{param} + FLOW_CONTENT,
        :valid_attributes => CORE_ATTRIBUTES + %w{codebase archive code object alt name width height align hspace vspace},
        :spec => 'http://www.w3.org/TR/html401/struct/objects.html#h-13.4'

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

      tag :isindex, :newline_before => true, :content_allowed => false,
        :valid_attributes => CORE_ATTRIBUTES + I18N_ATTRIBUTES + %w{prompt},
        :spec => 'http://www.w3.org/TR/html401/sgml/loosedtd.html#isindex'



      %w{body blockquote map form noscript}.each do |block_content_tag_name|
        modify_tag(block_content_tag_name) { |t| t.can_enclose += TRANSITIONAL_BLOCK_CONTENT }
      end

      %w{span h1 h2 h3 h4 h5 h6 address em strong dfn code samp kbd var cite abbr acronym q sub sup p pre dt caption} +
        %w{a tt i b big small label legend strike s u font}.each do |inline_content_tag_name|
        modify_tag(inline_content_tag_name) { |t| t.can_enclose += TRANSITIONAL_INLINE_CONTENT }
      end

      %w{div ins del li dd th td object button fieldset center applet}.each do |flow_content_tag_name|
        modify_tag(flow_content_tag_name) { |t| t.can_enclose += TRANSITIONAL_FLOW_CONTENT }
      end


      BGCOLORS_ATTRIBUTES = %w{bgcolor text link vlink alink}

      modify_tag(:html) { |t| t.valid_attributes += %w{version} }

      modify_tag(:body) { |t| t.valid_attributes += %w{background} + BGCOLORS_ATTRIBUTES }
      modify_tag(:div) { |t| t.valid_attributes += %w{align} }
      modify_tag(:h1) { |t| t.valid_attributes += %w{align} }
      modify_tag(:h2) { |t| t.valid_attributes += %w{align} }
      modify_tag(:h3) { |t| t.valid_attributes += %w{align} }
      modify_tag(:h4) { |t| t.valid_attributes += %w{align} }
      modify_tag(:h5) { |t| t.valid_attributes += %w{align} }
      modify_tag(:h6) { |t| t.valid_attributes += %w{align} }

      modify_tag(:p) { |t| t.valid_attributes += %w{align} }
      modify_tag(:br) { |t| t.valid_attributes += %w{clear} }
      modify_tag(:pre) { |t| t.valid_attributes += %w{width} }

      modify_tag(:ul) { |t| t.valid_attributes += %w{type compact} }
      modify_tag(:ol) { |t| t.valid_attributes += %w{type compact start} }
      modify_tag(:li) { |t| t.valid_attributes += %w{type value} }
      modify_tag(:dl) { |t| t.valid_attributes += %w{compact} }

      modify_tag(:table) { |t| t.valid_attributes += %w{align bgcolor} }
      modify_tag(:caption) { |t| t.valid_attributes += %w{align} }
      modify_tag(:tr) { |t| t.valid_attributes += %w{bgcolor} }
      modify_tag(:th) { |t| t.valid_attributes += %w{nowrap bgcolor width height} }

      modify_tag(:a) { |t| t.valid_attributes += %w{target} }
      modify_tag(:link) { |t| t.valid_attributes += %w{target} }
      modify_tag(:base) { |t| t.valid_attributes += %w{target} }

      modify_tag(:img) { |t| t.valid_attributes += %w{align border hspace vspace} }
      modify_tag(:object) { |t| t.valid_attributes += %w{align border hspace vspace} }

      modify_tag(:area) { |t| t.valid_attributes += %w{target} }

      modify_tag(:hr) { |t| t.valid_attributes += %w{align noshade size width} }

      modify_tag(:form) { |t| t.valid_attributes += %w{target} }
      modify_tag(:input) { |t| t.valid_attributes += %w{align} }

      modify_tag(:legend) { |t| t.valid_attributes += %w{align} }
      modify_tag(:script) { |t| t.valid_attributes += %w{language} }
    end
  end
end
