require 'fortitude/doctypes/html4'

module Fortitude
  module Doctypes
    class Html4Transitional < Html4
      def initialize
        super(:html4_transitional, 'HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"')
      end
    end
  end
end
