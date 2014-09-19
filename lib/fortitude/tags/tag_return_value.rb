require 'fortitude/errors'

module Fortitude
  module Tags
    # TAG_RETURN_VALUE_SUPERCLASS = if defined?(::BasicObject) then ::BasicObject else ::Object end
    TAG_RETURN_VALUE_SUPERCLASS = ::Object

    class TagReturnValue < TAG_RETURN_VALUE_SUPERCLASS
      def method_missing(name, *args)
        ::Kernel.raise ::Fortitude::Errors::NoReturnValueFromTag.new(name)
      end
    end
  end
end
