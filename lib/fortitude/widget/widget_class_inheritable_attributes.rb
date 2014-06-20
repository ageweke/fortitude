require 'active_support'
require 'active_support/concern'

require 'fortitude/support/class_inheritable_attributes'

module Fortitude
  class Widget
    module WidgetClassInheritableAttributes
      extend ActiveSupport::Concern

      include Fortitude::Support::ClassInheritableAttributes

      included do
        _fortitude_class_inheritable_attribute :format_output, false, [ true, false ]
        _fortitude_class_inheritable_attribute :extra_assigns, :ignore, [ :error, :ignore, :use ]
        _fortitude_class_inheritable_attribute :automatic_helper_access, true, [ true, false ]
        _fortitude_class_inheritable_attribute :implicit_shared_variable_access, false, [ true, false ]
        _fortitude_class_inheritable_attribute :enforce_element_nesting_rules, false, [ true, false ]
        _fortitude_class_inheritable_attribute :enforce_attribute_rules, false, [ true, false ]
        _fortitude_class_inheritable_attribute :enforce_id_uniqueness, false, [ true, false ]
        _fortitude_class_inheritable_attribute :use_instance_variables_for_assigns, false, [ true, false ]
        _fortitude_class_inheritable_attribute :start_and_end_comments, false, [ true, false ]
        _fortitude_class_inheritable_attribute :translation_base, nil, lambda { |s| s.kind_of?(String) || s.kind_of?(Symbol) || s == nil }
        _fortitude_class_inheritable_attribute :close_void_tags, true, [ true, false ]
        _fortitude_class_inheritable_attribute :debug, false, [ true, false ]
      end
    end
  end
end
