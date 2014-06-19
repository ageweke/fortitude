require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module Localization
      extend ActiveSupport::Concern

      module ClassMethods
        # RUBY CALLBACK
        def method_added(method_name)
          super(method_name)
          check_localized_methods!
        end

        # RUBY CALLBACK
        def method_removed(method_name)
          super(method_name)
          check_localized_methods!
        end

        # RUBY CALL
        def include(*args)
          super(*args)
          check_localized_methods!
        end

        LOCALIZED_CONTENT_PREFIX = "localized_content_"

        # INTERNAL USE ONLY
        def check_localized_methods!(original_class = self)
          currently_has = instance_methods(true).detect { |i| i =~ /^#{LOCALIZED_CONTENT_PREFIX}/i }
          if currently_has != @last_localized_methods_check_has
            @last_localized_methods_check_has = currently_has
            rebuild_run_content!(:localized_methods_presence_changed, original_class)
          end
          direct_subclasses.each { |s| s.check_localized_methods!(original_class) }
        end

        # INTERNAL USE ONLY
        def has_localized_content_methods?
          !! (instance_methods(true).detect { |i| i =~ /^#{LOCALIZED_CONTENT_PREFIX}/i })
        end
        private :has_localized_content_methods?
      end

      # PUBLIC API
      def t(key, *args)
        base = self.class.translation_base
        if base && key.to_s =~ /^\./
          super("#{base}#{key}", *args)
        else
          super(key, *args)
        end
      end

      # PUBLIC API
      def ttext(key, *args)
        tag_text t(".#{key}", *args)
      end
    end
  end
end
