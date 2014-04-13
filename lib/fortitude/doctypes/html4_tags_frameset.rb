require 'fortitude/tag_store'
require 'fortitude/doctypes/html4_tags_transitional'

module Fortitude
  module Doctypes
    module Html4TagsFrameset
      extend Fortitude::TagStore

      class << self
        def delegate_tag_stores
          [ Fortitude::Doctypes::Html4TagsTransitional ]
        end
      end

      FRAMESET_BLOCK_CONTENT = %w{noframes}
      FRAMESET_FLOW_CONTENT = %w{noframes}

      %w{CORE_ATTRIBUTES FLOW_CONTENT ATTRS_ATTRIBUTES}.each do |constant_name|
        const_set(constant_name, Fortitude::Doctypes::Html4TagsTransitional.const_get(constant_name))
      end

      # HTML4.01 spec, section 16.2
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


      %w{body blockquote map form noscript}.each do |block_content_tag_name|
        modify_tag(block_content_tag_name) { |t| t.can_enclose += FRAMESET_BLOCK_CONTENT }
      end

      %w{div ins del li dd th td object button fieldset center applet noframes iframe}.each do |flow_content_tag_name|
        modify_tag(flow_content_tag_name) { |t| t.can_enclose += FRAMESET_FLOW_CONTENT }
      end


      modify_tag(:html) { |t| t.can_enclose += %w{frameset} }
    end
  end
end
