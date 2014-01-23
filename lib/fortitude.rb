require "fortitude/version"

class String
  FORTITUDE_BEFORE_STRING_ATTRIBUTES = " ".freeze

  def fortitude_append_as_attributes(o, prefix)
    o.concat(FORTITUDE_BEFORE_STRING_ATTRIBUTES)
    fortitude_append_escaped_string(o)
  end
end

module Fortitude
  # Your code goes here...
end

require 'fortitude/railtie' if defined?(Rails::Railtie)
require 'fortitude/widget'
require File.join(File.dirname(__FILE__), 'fortitude_native_ext')
