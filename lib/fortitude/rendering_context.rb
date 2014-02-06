require 'fortitude/instance_variable_set'

module Fortitude
  class RenderingContext
    attr_reader :output, :instance_variable_set

    def initialize(output, instance_variables_object)
      @instance_variable_set = Fortitude::InstanceVariableSet.new(instance_variables_object)
      @output = output
    end
  end
end
