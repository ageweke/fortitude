require 'fortitude/doctypes/xhtml10'

module Fortitude
  module Doctypes
    class Xhtml10Transitional < Xhtml10
      def initialize
        super(:xhtml10_transitional, 'html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"')
      end

      class << self
        def delegate_tag_stores
          [ Fortitude::Doctypes::Html4TagsTransitional ]
        end
      end
    end
  end
end
