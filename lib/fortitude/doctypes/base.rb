require 'fortitude/tags/tag_store'

module Fortitude
  module Doctypes
    class Base
      extend Fortitude::Tags::TagStore

      class << self
        def delegate_tag_stores
          if superclass.respond_to?(:tags)
            [ superclass ]
          else
            [ ]
          end
        end
      end

      attr_reader :name

      def initialize(name, doctype_line)
        @name = name
        @doctype_line = doctype_line
      end

      def tags
        self.class.tags
      end

      def declare!(w)
        w.doctype(@doctype_line)
      end

      def to_s
        "<Doctype #{name.inspect}>"
      end
    end
  end
end
