require 'fortitude/doctypes/html5'
require 'fortitude/doctypes/html4_strict'
require 'fortitude/doctypes/html4_transitional'
require 'fortitude/doctypes/html4_frameset'
require 'fortitude/doctypes/unknown_doctype'
require 'fortitude/doctypes/xhtml10_strict'
require 'fortitude/doctypes/xhtml10_transitional'
require 'fortitude/doctypes/xhtml10_frameset'
require 'fortitude/doctypes/xhtml11'

module Fortitude
  module Doctypes
    KNOWN_DOCTYPES = begin
      out = { }

      [
        Html5.new,

        Html4Strict.new,
        Html4Transitional.new,
        Html4Frameset.new,

        Xhtml10Strict.new,
        Xhtml10Transitional.new,
        Xhtml10Frameset.new,

        Xhtml11.new
      ].each do |doctype|
        out[doctype.name] = doctype
      end
    end

    def standard_doctype(type)
      out = KNOWN_DOCTYPES[type]
      unless out
        raise ArgumentError, "Unknown standard doctype #{type.inspect}; I know about: #{KNOWN_DOCTYPES.keys.inspect}"
      end
      out
    end
  end
end
