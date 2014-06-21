require 'fortitude/doctypes'
require 'fortitude/doctypes/base'

module Fortitude
  module Doctypes
    class Xhtml10 < Base
      def default_javascript_tag_attributes
        { :type => 'text/javascript'.freeze }.freeze
      end

      def needs_cdata_in_javascript_tag?
        true
      end

      def close_void_tags_must_be
        true
      end
    end
  end
end
