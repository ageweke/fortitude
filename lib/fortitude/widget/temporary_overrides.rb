require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module TemporaryOverrides
      extend ActiveSupport::Concern

      # PUBLIC API
      def with_element_nesting_rules(on_or_off)
        raise ArgumentError, "We aren't even enforcing nesting rules in the first place" if on_or_off && (! self.class.enforce_element_nesting_rules)
        @_fortitude_rendering_context.with_element_nesting_validation(on_or_off) { yield }
      end

      # PUBLIC API
      def with_attribute_rules(on_or_off)
        raise ArgumentError, "We aren't even enforcing attribute rules in the first place" if on_or_off && (! self.class.enforce_attribute_rules)
        @_fortitude_rendering_context.with_attribute_validation(on_or_off) { yield }
      end

      # PUBLIC API
      def with_id_uniqueness(on_or_off)
        raise ArgumentError, "We aren't even enforcing ID uniqueness in the first place" if on_or_off && (! self.class.enforce_id_uniqueness)
        @_fortitude_rendering_context.with_id_uniqueness(on_or_off) { yield }
      end
    end
  end
end
