module Fortitude
  class InstanceVariableSet
    def initialize(target_object)
      @target_object = target_object
    end

    def [](name)
      target_object.instance_variable_get("@#{name}")
    end

    def []=(name, value)
      target_object.instance_variable_set("@#{name}", value)
    end

    def keys
      target_object.instance_variables.map do |instance_variable_name|
        $1.to_sym if instance_variable_name.to_s =~ /^@(.*)$/
      end.compact
    end

    def each
      keys.each { |k| yield k, self[k] }
    end

    def with_instance_variable_copying(widget)
      before_copy = widget.instance_variables
      skip_copy = before_copy - target_object.instance_variables

      copy_to_widget(widget)
      begin
        yield
      ensure
        copy_from_widget(widget, skip_copy)
      end
    end

    private
    def copy_to_widget(widget)
      target_object.instance_variables.each do |instance_variable_name|
        value = target_object.instance_variable_get(instance_variable_name)
        widget.instance_variable_set(instance_variable_name, value)
      end
    end

    def copy_from_widget(widget, exclude_variables = [ ])
      (widget.instance_variables - exclude_variables).each do |instance_variable_name|
        next if instance_variable_name =~ /^@_fortitude_/

        value = widget.instance_variable_get(instance_variable_name)
        target_object.instance_variable_set(instance_variable_name, value)
      end
    end

    attr_reader :target_object
  end
end
