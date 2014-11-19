require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module Localization
      extend ActiveSupport::Concern

      LOCALIZED_CONTENT_PREFIX = "localized_content_"

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
