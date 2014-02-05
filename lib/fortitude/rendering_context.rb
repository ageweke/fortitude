module Fortitude
  class RenderingContext
    attr_reader :output

    def initialize(options = { })
      options.assert_valid_keys(:instance_variables_object, :output)

      @instance_variables_object = options[:instance_variables_object]
      @output = (options[:output] || "").html_safe
    end

    def set_instance_variable(name, value)
      @instance_variables_object.instance_variable_set("@#{name}", value)
    end

    def get_instance_variable(name)
      @instance_variables_object.instance_variable_get("@#{name}")
    end
  end
end
