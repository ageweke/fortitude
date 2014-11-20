require 'active_support'
require 'active_support/concern'

require 'fortitude/method_templates/simple_compiled_template'

module Fortitude
  class Widget
    module Integration
      extend ActiveSupport::Concern

      module ClassMethods
        # INTERNAL USE ONLY
        def rebuilding(what, why, klass, &block)
          ActiveSupport::Notifications.instrument("fortitude.rebuilding", :what => what, :why => why, :originating_class => klass, :class => self, &block)
        end
        private :rebuilding

        def invalidating(what, why, klass, &block)
          ActiveSupport::Notifications.instrument("fortitude.invalidating", :what => what, :why => why, :originating_class => klass, :class => self, &block)
        end
        private :invalidating

        # INTERNAL USE ONLY
        def rebuild_text_methods!(why, klass = self)
          rebuilding(:text_methods, why, klass) do
            class_eval(Fortitude::MethodTemplates::SimpleCompiledTemplate.template('text_method_template').result(
              :format_output => format_output,
              :record_emitting_tag => self._fortitude_record_emitting_tag?))
            direct_subclasses.each { |s| s.rebuild_text_methods!(why, klass) }
          end
        end
      end

      # RUBY CALLBACK
      def method_missing(name, *args, &block)
        if self.class.extra_assigns == :use
          ivar_name = self.class.instance_variable_name_for_need(name)
          return instance_variable_get(ivar_name) if instance_variable_defined?(ivar_name)
        end

        if self.class.automatic_helper_access && @_fortitude_rendering_context && @_fortitude_rendering_context.helpers_object && @_fortitude_rendering_context.helpers_object.respond_to?(name, true)
          @_fortitude_rendering_context.helpers_object.send(name, *args, &block)
        else
          super(name, *args, &block)
        end
      end

      included do
        _fortitude_on_class_inheritable_attribute_change(
          :format_output, :enforce_element_nesting_rules, :record_tag_emission) do |attribute_name, old_value, new_value|
          rebuild_text_methods!(:"#{attribute_name}_changed")
        end

        _fortitude_on_class_inheritable_attribute_change(
          :format_output, :close_void_tags, :enforce_element_nesting_rules,
          :enforce_attribute_rules, :enforce_id_uniqueness, :record_tag_emission) do |attribute_name, old_value, new_value|
          rebuild_tag_methods!(:"#{attribute_name}_changed")
        end

        _fortitude_on_class_inheritable_attribute_change(
          :debug, :extra_assigns, :use_instance_variables_for_assigns) do |attribute_name, old_value, new_value|
          invalidate_needs!(:"#{attribute_name}_changed")
        end

        _fortitude_on_class_inheritable_attribute_change(:implicit_shared_variable_access) do |attribute_name, old_value, new_value|
          if new_value
            around_content :transfer_shared_variables
          else
            remove_around_content :transfer_shared_variables, :fail_if_not_present => false
          end
        end

        _fortitude_on_class_inheritable_attribute_change(:start_and_end_comments) do |attribute_name, old_value, new_value|
          if new_value
            around_content :start_and_end_comments
          else
            remove_around_content :start_and_end_comments, :fail_if_not_present => false
          end
        end

        _fortitude_on_class_inheritable_attribute_change(:use_localized_content_methods) do |attribute_name, old_value, new_value|
          rebuild_run_content!(:use_localized_content_methods_changed)
        end
      end
    end
  end
end
