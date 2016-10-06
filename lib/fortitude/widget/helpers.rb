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

            block_transform = if (yielded_methods_to_output = options[:output_yielded_methods])
              "effective_block = ::Fortitude::Rails::YieldedObjectOutputter.wrap_block_as_needed(self, #{name.inspect}, block, #{yielded_methods_to_output.inspect})"
            else
              "effective_block = block"
            end

            call_part = if source_method_name.to_s =~ /\=\s*$/
              ".send(:#{source_method_name}, "
            else
              ".#{source_method_name}("
            end

            text = <<-EOS
    def #{name}(*args, &block)
      #{block_transform}
      #{prefix}(@_fortitude_rendering_context.helpers_object#{call_part}*args, &effective_block))#{suffix}
    end
EOS

            helpers_module.module_eval(text)
          end
        end
      end
    end
  end
end
