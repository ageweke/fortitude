module Fortitude
  module DisabledDynamicMethods
    attr_accessor :_fortitude_static_method_name, :_fortitude_static_method_class

    def assigns
      _fortitude_dynamic_disabled!(:assigns)
    end

    def rendering_context
      _fortitude_dynamic_disabled!(:rendering_context)
    end

    def widget(*args)
      _fortitude_dynamic_disabled!(:widget)
    end

    def render(*args)
      _fortitude_dynamic_disabled!(:render)
    end

    def output_buffer
      _fortitude_dynamic_disabled!(:output_buffer)
    end

    def shared_variables
      _fortitude_dynamic_disabled!(:shared_variables)
    end

    def _fortitude_dynamic_disabled!(method_name)
      raise Fortitude::Errors::DynamicAccessFromStaticMethod.new(_fortitude_static_method_class, _fortitude_static_method_name, method_name)
    end
  end
end
