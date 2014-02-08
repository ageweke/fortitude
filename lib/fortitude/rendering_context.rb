require 'fortitude/instance_variable_set'

module Fortitude
  class RenderingContext
    attr_reader :output, :instance_variable_set, :helpers_object

    def initialize(helpers_object, instance_variables_object, output_buffer, yield_block)
      @helpers_object = helpers_object
      @instance_variable_set = Fortitude::InstanceVariableSet.new(instance_variables_object)
      @output = ""
      @output_buffer = output_buffer
      @yield_block = yield_block
    end

    def yield_to_view(*args)
      raise "No layout to yield to!" unless yield_block
      @output << @yield_block.call(*args)
    end

    def flush!
      if @output_buffer
        @output_buffer << @output.html_safe
        @output.clear
      end
    end
  end
end
