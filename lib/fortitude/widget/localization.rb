require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module Localization
      extend ActiveSupport::Concern

      LOCALIZED_CONTENT_PREFIX = "localized_content_"

      # PUBLIC API
      #
      # This method is defined here for two reasons:
      #
      # 1. It supports our class-level translation_base feature.
      # 2. It makes sure #t is a method directly defined on Fortitude::Widget. If not, automatic_helper_access (which
      #    is on by default) will make sure calls to #t still work, but via #method_missing each time. Since
      #    #method_missing is slow, this is a significant performance loss (~15% in real-world apps, ~45% in
      #    microbenchmarks that do nothing but call #t). Defining this here makes it go even faster.
      def t(key, *args)
        base = self.class.translation_base
        if base && key.to_s =~ /^\./
          invoke_helper(:t, "#{base}#{key}", *args)
        else
          invoke_helper(:t, key, *args)
        end
      end

      # PUBLIC API
      def ttext(key, *args)
        tag_text t(".#{key}", *args)
      end
    end
  end
end
