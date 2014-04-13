require 'fortitude/doctypes/html4'
require 'fortitude/doctypes/html4_tags_frameset'

module Fortitude
  module Doctypes
    class Html4Frameset < Html4Transitional
      def initialize
        super(:html4_frameset, 'HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd"')
      end

      class << self
        def delegate_tag_stores
          [ Fortitude::Doctypes::Html4TagsFrameset ]
        end
      end
    end
  end
end
