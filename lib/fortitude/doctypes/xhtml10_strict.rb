require 'fortitude/doctypes/xhtml10'

module Fortitude
  module Doctypes
    class Xhtml10Strict < Xhtml10
      def initialize
        super(:xhtml10_strict, 'html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"')
      end
    end
  end
end
