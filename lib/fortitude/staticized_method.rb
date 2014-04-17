module Fortitude
  class StaticizedMethod
    def initialize(widget_class, method_name, options = { })
      @widget_class = widget_class
      @method_name = method_name

      @output_by_locale = { }
      @has_yield = false

      @options = options
      @options.assert_valid_keys(:locale_support)

      set_constant!
    end

    def run!(widget)
      locale = locale_support? ? widget.widget_locale : nil
      output = (@output_by_locale[locale] ||= generate_content!(widget))

      if output.kind_of?(Array)
        widget.rawtext(output[0])
        yield
        widget.rawtext(output[1])
      else
        widget.rawtext(output)
      end
    end

    def create_method!
      unless widget_class.instance_methods.map(&:to_s).include?(dynamic_method_name.to_s)
        widget_class.send(:alias_method, dynamic_method_name, method_name)
      end

      widget_class.class_eval <<-EOS
  def #{method_name}
    #{constant_name}.run!(self) { yield }
  end
EOS
    end

    private
    attr_reader :widget_class, :method_name, :output_by_locale, :has_yield, :options

    def locale_support?
      ! (options.has_key?(:locale_support) && (! options[:locale_support]))
    end

    def generate_content!(widget)
      yielded = false
      pre_yield = nil

      result = widget.capture do
        widget.with_staticness_enforced(method_name) do
          widget.send(dynamic_method_name) do
            raise "This method yields more than once; you can't make it static" if yielded
            pre_yield = widget.output_buffer.dup
            yielded = true
            widget.output_buffer.replace('')
          end
        end
      end

      @has_yield = yielded

      if yielded
        [ pre_yield, result ]
      else
        result
      end
    end

    def set_constant!
      widget_class.send(:remove_const, constant_name) if widget_class.const_defined?(constant_name)
      widget_class.const_set(constant_name, self)
    end

    def constant_name
      "FORTITUDE_STATICIZED_METHOD_#{method_name.to_s.upcase}"
    end

    def dynamic_method_name
      "_#{method_name}_dynamic".to_sym
    end
  end
end
