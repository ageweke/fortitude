require "fortitude/version"
require "fortitude/rendering_context"

module Fortitude
  # Your code goes here...
end

require 'fortitude/railtie' if defined?(Rails::Railtie)
require 'fortitude/widget'
require File.join(File.dirname(__FILE__), 'fortitude_native_ext')
