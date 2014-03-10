module Fortitude
  class StaticizedMethod
    def initialize(widget_class, method_name, helpers_object)
      @widget_class = widget_class
      @method_name = method_name
      @helpers_object = helpers_object

      @output_by_locale = { }
      @has_yield = false

      set_constant!
    end

    def output_for(locale)
      output_by_locale[locale] ||= generate_output_for_locale(locale)
    end

    def create_method!
      widget_class.send(:alias_method, dynamic_method_name, method_name) unless widget_class.instance_methods.include?(dynamic_method_name)

      results_no_locale = output_for(nil)

      method_text = if has_yield
        "rawtext results[0]; yield; rawtext results[1]"
      else
        "rawtext results"
      end

      widget_class.class_eval <<-EOS
  def #{static_method_name}
    results = #{constant_name}.output_for(widget_locale)
    #{method_text}
  end
EOS

      widget_class.send(:alias_method, method_name, static_method_name)
    end

    private
    attr_reader :widget_class, :method_name, :helpers_object, :output_by_locale, :has_yield

    def set_constant!
      widget_class.send(:remove_const, constant_name) if widget_class.const_defined?(constant_name)
      widget_class.const_set(constant_name, self)
    end

    def constant_name
      "FORTITUDE_STATICIZED_METHOD_#{method_name.to_s.upcase}"
    end

    def static_method_name
      "_#{method_name}_static".to_sym
    end

    def dynamic_method_name
      "_#{method_name}_dynamic".to_sym
    end

    def generate_output_for_locale(locale)
      instance = staticization_subclass.new
      instance._enforce_staticness!(widget_class, method_name)

      ho = helpers_object
      ho = ho.call if ho.respond_to?(:call)

      results = instance._one_method_to_html(dynamic_method_name, locale, ho)
      @has_yield = results.kind_of?(Array)
      results.freeze
    end

    def staticization_subclass
      @staticization_subclass ||= begin
        out = Class.new(@widget_class)
        out.send(:define_method, :initialize) { }
        out
      end
    end
  end
end
