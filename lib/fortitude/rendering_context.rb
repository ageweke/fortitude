require 'fortitude/instance_variable_set'

module Fortitude
  class RenderingContext
    attr_reader :output, :instance_variable_set

    def initialize(instance_variables_object, output_buffer, yield_block)
      @instance_variable_set = Fortitude::InstanceVariableSet.new(instance_variables_object)
      @output = ""
      @output_buffer = output_buffer
      @yield_block = yield_block
    end

    def yield_to_view(*args)
      @output << @yield_block.call(*args)
    end

    def flush!
      @output_buffer << @output.html_safe
      @output.clear
    end
  end
end
