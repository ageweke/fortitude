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
          _fortitude_read_class_inheritable_attribute(attribute_name, instance_variable_name)
        else
          _fortitude_write_class_inheritable_attribute(attribute_name, instance_variable_name, allowable_values, args[0])
        end
      end

      def _fortitude_read_class_inheritable_attribute(attribute_name, instance_variable_name)
        return instance_variable_get(instance_variable_name) if instance_variable_defined?(instance_variable_name)
        return superclass.send(attribute_name) if superclass.respond_to?(attribute_name)
        raise "Fortitude class-inheritable attribute error: there should always be a declared value for #{attribute_name} at the top of the inheritance hierarchy somewhere"
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
        instance_variable_set(instance_variable_name, new_value)
        changed_method = "_fortitude_#{attribute_name}_changed!"
        send(changed_method, new_value) if respond_to?(changed_method)
        new_value
      end

      def _fortitude_class_inheritable_attribute(attribute_name, default_value, allowable_values)
        metaclass = (class << self; self; end)

        metaclass.send(:define_method, attribute_name) do |*args|
          _fortitude_invoke_class_inheritable_attribute(attribute_name, allowable_values, *args)
        end

        send(attribute_name, default_value)
      end
    end
  end
end
