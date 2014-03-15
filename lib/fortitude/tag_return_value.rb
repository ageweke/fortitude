require 'fortitude/errors'

module Fortitude
  class TagReturnValue < BasicObject
    def method_missing(name, *args)
      ::Kernel.raise ::Fortitude::Errors::NoReturnValueFromTag.new(name)
    end
  end
end
