module Fortitude
  class StaticizedMethod
    def initialize(widget_class, method_name)
      @widget_class = widget_class
      @method_name = method_name

      @output_by_locale = { }
      @has_yield = false

      set_constant!
    end

    def output_for(locale)
      output_by_locale[locale] ||= generate_output_for_locale(locale)
    end

    def run!(widget)
      locale = widget.widget_locale
      output = (@output_by_locale[locale] ||= generate_content!(widget, locale))

      if output.kind_of?(Array)
        widget.rawtext(output[0])
        yield
        widget.rawtext(output[1])
      else
        widget.rawtext(output)
      end
    end

    def generate_content!(widget, locale)
      yielded = false
      pre_yield = nil

      result = widget.capture do
        widget.with_staticness_enforced(method_name) do
          widget.send(dynamic_method_name) do
            raise "This method yields more than once; you can't make it static" if yielded
            pre_yield = widget.output_buffer.dup
            yielded = true
            widget.output_buffer.clear
          end
        end
      end

      if yielded
        [ pre_yield, result ]
      else
        result
      end
    end

    def create_method!
      unless widget_class.instance_methods.include?(dynamic_method_name)
        widget_class.send(:alias_method, dynamic_method_name, method_name)
      end

      widget_class.class_eval <<-EOS
  def #{method_name}
    #{constant_name}.run!(self) { yield }
  end
EOS
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

      ho = helpers_object
      ho = ho.call(instance) if ho.respond_to?(:call)

      instance._enforce_staticness!(widget_class, method_name)

      results = instance._one_method_to_html(dynamic_method_name, locale, ho)
      @has_yield = results.kind_of?(Array)

      results = results.map(&:freeze) if results.kind_of?(Array)
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
