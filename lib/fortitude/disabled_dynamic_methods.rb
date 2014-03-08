module Fortitude
  module DisabledDynamicMethods
    attr_accessor :_fortitude_static_method_name

    def assigns
      _fortitude_dynamic_disabled!(:assigns)
    end

    def _fortitude_dynamic_disabled!(method_name)
      raise Fortitude::Errors::DynamicAccessFromStaticMethod.new(self, _fortitude_static_method_name, method_name)
    end
  end
end
