require 'fortitude/doctypes'
require 'fortitude/doctypes/xhtml10'

module Fortitude
  module Doctypes
    class Xhtml10Frameset < Xhtml10
      def initialize
        super(:xhtml10_frameset, 'html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"')
      end

      class << self
        def delegate_tag_stores
          [ Fortitude::Doctypes::Html4TagsFrameset ]
        end
      end
    end
  end
end
