require 'fortitude/doctypes/html4'

module Fortitude
  module Doctypes
    class Html4Frameset < Html4Transitional
      def initialize
        super(:html4_frameset, 'HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd"')
      end

      # HTML4.01 spec, section 16.2
      # TRANSITIONAL / FRAMESET:
      tag :frameset, :newline_before => true, :can_enclose => %w{frameset frame noframes},
        :valid_attributes => CORE_ATTRIBUTES + %w{rows cols onload onunload},
        :spec => 'http://www.w3.org/TR/html401/present/frames.html#h-16.2.1'
      # TRANSITIONAL / FRAMESET:
      tag :frame, :newline_before => true, :content_allowed => false,
        :valid_attributes => CORE_ATTRIBUTES + %w{longdesc name src frameborder marginwidth marginheight noresize scrolling},
        :spec => 'http://www.w3.org/TR/html401/present/frames.html#h-16.2.2'
      # TRANSITIONAL / FRAMESET:
      tag :noframes, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :valid_attributes => ATTRS_ATTRIBUTES,
        :spec => 'http://www.w3.org/TR/html401/present/frames.html#h-16.4.1'

      # HTML4.01 spec, section 16.5
      # TRANSITIONAL / FRAMESET:
      tag :iframe, :newline_before => true, :can_enclose => FLOW_CONTENT,
        :valid_attributes => CORE_ATTRIBUTES + %w{longdesc name src frameborder marginwidth marginheight scrolling} +
                             %w{align height width},
        :spec => 'http://www.w3.org/TR/html401/present/frames.html#h-16.5'

      modify_tag(:html) { |t| t.can_enclose += %w{frameset} }
    end
  end
end
