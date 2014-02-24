module Fortitude
  module Doctypes
    class Base
      attr_reader :name

      def initialize(name, doctype_line)
        @name = name
        @doctype_line = doctype_line
      end

      def declare!(w)
        w.rawtext "<!DOCTYPE #{@doctype_line}>"
      end
    end
  end
end
