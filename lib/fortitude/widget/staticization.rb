require 'active_support'
require 'active_support/concern'

require 'fortitude/support/staticized_method'

module Fortitude
  class Widget
    module Staticization
      extend ActiveSupport::Concern

      module ClassMethods
        # PUBLIC API
        def static(*method_names)
          options = method_names.extract_options!

          method_names.each do |method_name|
            method_name = method_name.to_sym
            staticized_method = Fortitude::Support::StaticizedMethod.new(self, method_name, options)
            staticized_method.create_method!
          end
        end
      end

      METHODS_TO_DISABLE_WHEN_STATIC = [ :assigns, :shared_variables ]

      # INTERNAL USE ONLY
      def with_staticness_enforced(static_method_name, &block)
        methods_to_disable = METHODS_TO_DISABLE_WHEN_STATIC + self.class.needs_as_hash.keys
        metaclass = (class << self; self; end)

        methods_to_disable.each do |method_name|
          metaclass.class_eval do
            alias_method "_static_disabled_#{method_name}", method_name
            define_method(method_name) { raise Fortitude::Errors::DynamicAccessFromStaticMethod.new(self, static_method_name, method_name) }
          end
        end

        begin
          block.call
        ensure
          methods_to_disable.each do |method_name|
            metaclass.class_eval do
              alias_method method_name, "_static_disabled_#{method_name}"
            end
          end
        end
      end
    end
  end
end
