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
    end
  end
end
