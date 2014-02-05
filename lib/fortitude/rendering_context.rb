require 'fortitude/instance_variable_set'

module Fortitude
  class RenderingContext
    attr_reader :output, :instance_variable_set

    def initialize(options = { })
      options.assert_valid_keys(:instance_variables_object, :output)

      @instance_variable_set = Fortitude::InstanceVariableSet.new(options[:instance_variables_object]) if options[:instance_variables_object]
      @output = (options[:output] || "").html_safe
    end
  end
end
