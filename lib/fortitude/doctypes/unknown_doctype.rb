require 'fortitude/doctypes'
require 'fortitude/doctypes/base'

module Fortitude
  module Doctypes
    class UnknownDoctype < Base
      def initialize(declaration = nil)
        super(:unknown, declaration)
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
