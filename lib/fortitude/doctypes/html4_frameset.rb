require 'fortitude/doctypes/html4'

module Fortitude
  module Doctypes
    class Html4Frameset < Html4
      def initialize
        super(:html4_frameset, 'HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd"')
      end
    end
  end
end
