module Fortitude
  module Rails
    YIELDED_OBJECT_OUTPUTTER_SUPERCLASS = if defined?(::BasicObject) then ::BasicObject else ::Object end
    class YieldedObjectOutputter < YIELDED_OBJECT_OUTPUTTER_SUPERCLASS
      class << self
        def wrap_block_as_needed(output_target, for_method_name, original_block, yielded_methods_to_output)
          if original_block && yielded_methods_to_output && original_block.arity > 0
            lambda do |*args|
              yielded_object = args.shift
              outputter = new(output_target, yielded_object, for_method_name, yielded_methods_to_output)
              original_block.call(outputter, *args)
            end
          else
            original_block
          end
        end
      end

      def initialize(output_target, yielded_object, for_method_name, method_names)
        @output_target = output_target
        @yielded_object = yielded_object
        @for_method_name = for_method_name
        @method_names_hash = { }
        method_names.each do |method_name|
          @method_names_hash[method_name.to_sym] = true
        end
      end

      EMPTY_RETURN_VALUE = ''.freeze

      def method_missing(method_name, *args, &block)
        method_name = method_name.to_sym
        method_name = args.shift if method_name == :send

        if @method_names_hash[method_name.to_sym]
          block = ::Fortitude::Rails::YieldedObjectOutputter.wrap_block_as_needed(@output_target, method_name, block, @method_names_hash.keys)
          return_value = @yielded_object.send(method_name, *args, &block)
          @output_target.rawtext(return_value)
          EMPTY_RETURN_VALUE
        else
          @yielded_object.send(method_name, *args, &block)
        end
      end

      def respond_to?(symbol, include_all = false)
        @yielded_object.respond_to?(symbol, include_all)
      end
    end
  end
end
