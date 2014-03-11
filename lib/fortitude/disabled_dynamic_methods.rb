module Fortitude
  module DisabledDynamicMethods
    attr_accessor :_fortitude_static_method_name, :_fortitude_static_method_class

    def assigns
      _fortitude_dynamic_disabled!(:assigns)
    end

    def shared_variables
      _fortitude_dynamic_disabled!(:shared_variables)
    end

    def _fortitude_dynamic_disabled!(method_name)
      raise Fortitude::Errors::DynamicAccessFromStaticMethod.new(_fortitude_static_method_class, _fortitude_static_method_name, method_name)
    end
  end
end
