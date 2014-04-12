require 'fortitude/doctypes/html4'

module Fortitude
  module Doctypes
    class Html4Transitional < Html4
      def initialize(name = nil, dtd = nil)
        super(name || :html4_transitional, dtd || 'HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"')
      end

      # TRANSITIONAL
      tag :dir, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES + %w{compact},
        :can_enclose => %w{li},
        :spec => 'http://www.w3.org/TR/html401/sgml/loosedtd.html#dir'
      # TRANSITIONAL
      tag :menu, :newline_before => true, :valid_attributes => ATTRS_ATTRIBUTES + %w{menu},
        :can_enclose => %w{li},
        :spec => 'http://www.w3.org/TR/html401/sgml/loosedtd.html#dir'


      BGCOLORS_ATTRIBUTES = %w{bgcolor text link vlink alink}

      modify_tag(:body) { |t| t.valid_attributes += %w{background} + BGCOLORS_ATTRIBUTES }
    end
  end
end
