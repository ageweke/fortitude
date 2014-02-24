module Fortitude
  module Doctypes
    class Base
      attr_reader :name

      def initialize(name, doctype_line)
        @name = name
        @doctype_line = doctype_line
      end

      def declare!(w)
        w.doctype @doctype_line
      end

      def to_s
        "<Doctype #{name.inspect}>"
      end
    end
  end
end
