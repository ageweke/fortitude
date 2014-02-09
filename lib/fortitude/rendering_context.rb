require 'fortitude/instance_variable_set'

module Fortitude
  class RenderingContext
    attr_reader :output, :instance_variable_set, :helpers_object

    def initialize(helpers_object, instance_variables_object, output_buffer_object, yield_block)
      @helpers_object = helpers_object
      @instance_variable_set = Fortitude::InstanceVariableSet.new(instance_variables_object)

      if output_buffer_object
        @output_buffer_object = output_buffer_object
      else
        @output_buffer_object = OpenStruct.new
        @output_buffer_object.output_buffer = ActionView::OutputBuffer.new
        output_buffer.force_encoding(Encoding::UTF_8)
      end

      @yield_block = yield_block
    end

    def output
      @output_buffer_object.output_buffer
    end

    def yield_to_view(*args)
      raise "No layout to yield to!" unless @yield_block
      output << @yield_block.call(*args)
    end

    def flush!
      # nothing here right now
    end
  end
end
