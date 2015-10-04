require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module Localization
      extend ActiveSupport::Concern

      LOCALIZED_CONTENT_PREFIX = "localized_content_"

      # We do some funny voodoo here, for performance reasons. In localized Rails applications, #t
      # ("translate this string") is called a LOT. Even small slowdowns in its performance can have a big impact.
      # As such, we work hard to make this go fast.
      #
      # We'd like to support our .translation_base method, which prepends a translation base to any keys passed to #t
      # that aren't globally specified (e.g., ".foo.bar", not "foo.bar"), but with as little overhead as possible.
      # (Most people won't use that feature.) So here's what we do:
      #
      # - We create one method, #_fortitude_t_without_translation_base, that simply passes through to the helper
      #   method #t on whatever our helpers object is. This is the "fast" method.
      # - We create a second method, #_fortutude_t_with_translation_base, that checks the translation_base and applies
      #   it as needed before calling through to the method #t on whatever our helpers object is. This is the "slow"
      #   method.
      # - By default, we alias the fast method to #t. However, we also have a callback whenever translation_base
      #   is changed (_fortitude_on_class_inheritable_attribute_change(:translation_base), in
      #   lib/fortitude/widget/integration.rb) that calls our class method
      #   _fortitude_ensure_translation_base_supported_if_needed!. In turn, that checks recursively to see if _any_
      #   widget is using the translation_base feature, and, if so, aliases the slow method to #t -- otherwise, it
      #   aliases the fast method to #t.
      #
      # The net result is that we only have to use the slow method if anybody's actually using the translation_base
      # feature. Otherwise, we can use the fast method. While both of them are plenty "fast" according to most
      # standards, the difference in performance between them is significant enough (~10-15%) that it makes sense
      # to perform this optimization. Again, real-world localized Rails applications call #t a _lot_.

      # INTERNAL USE ONLY
      def _fortitude_t_with_translation_base(key, *args)
        base = self.class.translation_base
        if base && key.to_s =~ /^\./
          invoke_helper(:t, "#{base}#{key}", *args)
        else
          invoke_helper(:t, key, *args)
        end
      end

      # INTERNAL USE ONLY
      def _fortitude_t_without_translation_base(*args)
        invoke_helper(:t, *args)
      end

      # PUBLIC API
      alias_method :t, :_fortitude_t_without_translation_base

      module ClassMethods
        # INTERNAL USE ONLY
        def _fortitude_ensure_translation_base_supported_if_needed!
          unless equal?(::Fortitude::Widget)
            raise ArgumentError, "You must only ever call this on Fortitude::Widget, not #{self}"
          end

          if _fortitude_translation_base_support_needed?
            alias_method :t, :_fortitude_t_with_translation_base
          else
            alias_method :t, :_fortitude_t_without_translation_base
          end
        end

        # INTERNAL USE ONLY
        def _fortitude_translation_base_support_needed?
          _fortitude_translation_base_support_needed_for_this_class? ||
            (direct_subclasses.any?(&:_fortitude_translation_base_support_needed?))
        end

        # INTERNAL USE ONLY
        def _fortitude_translation_base_support_needed_for_this_class?
          translation_base && translation_base.to_s.strip.length > 0
        end
      end

      # PUBLIC API
      def ttext(key, *args)
        tag_text t(".#{key}", *args)
      end
    end
  end
end
