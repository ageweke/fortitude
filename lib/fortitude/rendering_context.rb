require 'fortitude/instance_variable_set'

module Fortitude
  class RenderingContext
    attr_reader :output_buffer_holder, :instance_variable_set, :helpers_object

    def initialize(options)
      options.assert_valid_keys(:delegate_object, :output_buffer_holder, :helpers_object, :instance_variables_object, :yield_block)

      @output_buffer_holder = options[:output_buffer_holder]
      if (! @output_buffer_holder) && options[:delegate_object] && options[:delegate_object].respond_to?(:output_buffer)
        @output_buffer_holder = options[:delegate_object]
      end
      @output_buffer_holder ||= OutputBufferHolder.new
      @helpers_object = options[:helpers_object] || options[:delegate_object] || Object.new

      instance_variables_object = options[:instance_variables_object] || options[:delegate_object] || Object.new
      @instance_variable_set = Fortitude::InstanceVariableSet.new(instance_variables_object)

      @indent = 0

      @yield_block = options[:yield_block]
    end

    def format_output?
      true
    end

    def newline_and_indent!
      @indent += 1
      newline!
    end

    def newline_and_unindent!
      @indent -= 1
      newline!
    end

    NEWLINE = "\n"

    def newline!
      @output_buffer_holder.output_buffer.original_concat(NEWLINE)
      indent!
    end

    def indent!
      @output_buffer_holder.output_buffer.original_concat("  " * @indent)
    end

    def yield_to_view(*args)
      raise "No layout to yield to!" unless @yield_block
      @output_buffer_holder.output_buffer << @yield_block.call(*args)
    end

    def flush!
      # nothing here right now
    end

    private
    class OutputBufferHolder
      attr_accessor :output_buffer

      def initialize
        if defined?(::ActionView::OutputBuffer)
          @output_buffer = ::ActionView::OutputBuffer.new
        else
          @output_buffer = ""
        end

        @output_buffer.force_encoding(Encoding::UTF_8)
      end
    end
  end
end
