module Fortitude
  module Rails
    YIELDED_OBJECT_OUTPUTTER_SUPERCLASS = if defined?(::BasicObject) then ::BasicObject else ::Object end
    class YieldedObjectOutputter < YIELDED_OBJECT_OUTPUTTER_SUPERCLASS
      def initialize(widget, yielded_object, method_names)
        @widget = widget
        @yielded_object = yielded_object
        @method_names_hash = { }
        method_names.each do |method_name|
          @method_names_hash[method_name.to_sym] = true
        end
      end

      EMPTY_RETURN_VALUE = ''.freeze

      def method_missing(method_name, *args, &block)
        return_value = @yielded_object.send(method_name, *args, &block)
        if @method_names_hash[method_name.to_sym]
          @widget.rawtext(return_value)
          EMPTY_RETURN_VALUE
        else
          return_value
        end
      end

      def respond_to?(symbol, include_all = false)
        @yielded_object.respond_to?(symbol, include_all)
      end
    end
  end
end
