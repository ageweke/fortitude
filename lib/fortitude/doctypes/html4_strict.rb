require 'fortitude/doctypes/html4'

module Fortitude
  module Doctypes
    class Html4Strict < Html4
      def initialize
        super(:html4_strict, 'HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"')
      end
    end
  end
end
