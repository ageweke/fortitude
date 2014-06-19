require 'fortitude/doctypes'
require 'fortitude/doctypes/html4'
require 'fortitude/doctypes/html4_tags_transitional'

module Fortitude
  module Doctypes
    class Html4Transitional < Html4
      def initialize(name = nil, dtd = nil)
        super(name || :html4_transitional, dtd || 'HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"')
      end

      class << self
        def delegate_tag_stores
          [ Fortitude::Doctypes::Html4TagsTransitional ]
        end
      end
    end
  end
end
