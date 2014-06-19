require 'fortitude/doctypes/base'

module Fortitude
  module Doctypes
    KNOWN_DOCTYPES = begin
      out = { }

      [
        Html5,

        Html4Strict,
        Html4Transitional,
        Html4Frameset,

        Xhtml10Strict,
        Xhtml10Transitional,
        Xhtml10Frameset,

        Xhtml11
      ].each do |doctype_class|
        doctype = doctype_class.new
        out[doctype.name] = doctype
      end

      out
    end

    class << self
      def standard_doctype(type)
        out = KNOWN_DOCTYPES[type]
        unless out
          raise ArgumentError, "Unknown standard doctype #{type.inspect}; I know about: #{KNOWN_DOCTYPES.keys.inspect}"
        end
        out
      end
    end
  end
end
