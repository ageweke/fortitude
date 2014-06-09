require 'active_support'
require 'active_support/concern'

module Fortitude
  module ClassInheritableAttributes
    extend ActiveSupport::Concern

    module ClassMethods
      def _fortitude_invoke_class_inheritable_attribute(attribute_name, allowable_values, *args)
        raise ArgumentError, "Invalid arguments: #{args.inspect}" if args.length > 1
        instance_variable_name = "@_fortitude_#{attribute_name}"
        if args.length == 0
          _fortitude_read_class_inheritable_attribute(attribute_name, instance_variable_name, false)
        else
          _fortitude_write_class_inheritable_attribute(attribute_name, instance_variable_name, allowable_values, args[0])
        end
      end

      def _fortitude_read_class_inheritable_attribute(attribute_name, instance_variable_name, allow_not_present)
        return instance_variable_get(instance_variable_name) if instance_variable_defined?(instance_variable_name)
        return superclass.send(attribute_name) if superclass.respond_to?(attribute_name)

        if allow_not_present
          :_fortitude_class_inheritable_attribute_not_present
        else
          raise "Fortitude class-inheritable attribute error: there should always be a declared value for #{attribute_name} at the top of the inheritance hierarchy somewhere"
        end
      end

      def _fortitude_write_class_inheritable_attribute(attribute_name, instance_variable_name, allowable_values, new_value)
        allowed = if allowable_values.respond_to?(:call)
          allowable_values.call(new_value)
        else
          allowable_values.include?(new_value)
        end

        if (! allowed)
          error = "#{attribute_name} cannot be set to #{new_value.inspect}"
          error << "; valid values are: #{allowable_values.inspect}" unless allowable_values.respond_to?(:call)
          raise ArgumentError, error
        end

        old_value = _fortitude_read_class_inheritable_attribute(attribute_name, instance_variable_name, true)

        instance_variable_set(instance_variable_name, new_value)

        if (old_value != :_fortitude_class_inheritable_attribute_not_present) && (new_value != old_value)
          _fortitude_class_inheritable_attribute_changed!(attribute_name, old_value, new_value)
        end

        new_value
      end

      def _fortitude_class_inheritable_attribute(attribute_name, default_value, allowable_values)
        metaclass = (class << self; self; end)

        metaclass.send(:define_method, attribute_name) do |*args|
          _fortitude_invoke_class_inheritable_attribute(attribute_name, allowable_values, *args)
        end

        send(attribute_name, default_value)
      end

      def _fortitude_on_class_inheritable_attribute_change(*attribute_names, &block)
        if attribute_names.length == 0
          raise ArgumentError, "You must pass at least one attribute name, not: #{attribute_names.inspect}"
        end

        @_fortitude_class_inheritable_attribute_change_callbacks ||= { }
        attribute_names.each do |attribute_name|
          @_fortitude_class_inheritable_attribute_change_callbacks[attribute_name] ||= [ ]
          @_fortitude_class_inheritable_attribute_change_callbacks[attribute_name] |= [ block ]
        end
      end

      def _fortitude_class_inheritable_attribute_callbacks_for(attribute_name)
        out = if superclass.respond_to?(:_fortitude_class_inheritable_attribute_callbacks_for)
          superclass._fortitude_class_inheritable_attribute_callbacks_for(attribute_name)
        else
          [ ]
        end

        @_fortitude_class_inheritable_attribute_change_callbacks ||= { }
        out += @_fortitude_class_inheritable_attribute_change_callbacks[attribute_name] || [ ]

        out
      end

      def _fortitude_class_inheritable_attribute_changed!(attribute_name, old_value, new_value)
        callbacks = _fortitude_class_inheritable_attribute_callbacks_for(attribute_name)
        # klass = self
        callbacks.each { |cb| instance_exec(attribute_name, old_value, new_value, &cb) }
      end
    end
  end
end
