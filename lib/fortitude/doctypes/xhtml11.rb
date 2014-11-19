require 'fortitude/doctypes'
require 'fortitude/doctypes/base'

module Fortitude
  module Doctypes
    class Xhtml11 < Base
      def initialize
        super(:xhtml11, 'html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"')
      end

      def default_javascript_tag_attributes
        { :type => 'text/javascript'.freeze }.freeze
      end

      def needs_cdata_in_javascript_tag?
        true
      end

      def allows_bare_attributes?
        false
      end

      def close_void_tags_must_be
        true
      end

      class << self
        def delegate_tag_stores
          [ Fortitude::Doctypes::Html4TagsStrict ]
        end
      end
    end
  end
end
