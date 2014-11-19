require 'fortitude/doctypes'
require 'fortitude/doctypes/base'
require 'fortitude/doctypes/html4_tags_strict'

module Fortitude
  module Doctypes
    class Html4 < Base
      def default_javascript_tag_attributes
        { :type => 'text/javascript'.freeze }.freeze
      end

      def needs_cdata_in_javascript_tag?
        false
      end

      def allows_bare_attributes?
        true
      end

      def close_void_tags_must_be
        false
      end
    end
  end
end
