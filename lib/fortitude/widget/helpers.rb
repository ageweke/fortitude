require 'active_support'
require 'active_support/concern'

require 'fortitude/rails/yielded_object_outputter'

module Fortitude
  class Widget
    module Helpers
      extend ActiveSupport::Concern

      # PUBLIC API
      def invoke_helper(name, *args, &block)
        @_fortitude_rendering_context.helpers_object.send(name, *args, &block)
      end

      module ClassMethods
        # PUBLIC API
        def helper(*args)
          options = args.extract_options!
          options.assert_valid_keys(:transform, :call, :output_yielded_methods)

          args.each do |name|
            source_method_name = options[:call] || name

            prefix = "return"
            suffix = ""
            case (transform = options[:transform])
            when :output_return_value
              prefix = "text"
              suffix = "; nil"
            when :return_output
              prefix = "return capture { "
              suffix = " }"
            when :none, nil, false then nil
            else raise ArgumentError, "Invalid value for :transform: #{transform.inspect}"
            end

            block_transform = "effective_block = block"

            yielded_methods = options[:output_yielded_methods]
            if yielded_methods
              block_transform = <<-EOS
      effective_block = lambda do |yielded_object|
        block.call(Fortitude::Rails::YieldedObjectOutputter.new(self, yielded_object, #{yielded_methods.inspect}))
      end
EOS
            end

            text = <<-EOS
    def #{name}(*args, &block)
      #{block_transform}
      #{prefix}(@_fortitude_rendering_context.helpers_object.#{source_method_name}(*args, &effective_block))#{suffix}
    end
EOS

            helpers_module.module_eval(text)
          end
        end
      end
    end
  end
end
