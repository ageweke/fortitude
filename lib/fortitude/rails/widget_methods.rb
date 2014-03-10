require 'active_support'

module Fortitude
  module Rails
    module WidgetMethods
      extend ActiveSupport::Concern

      def widget_locale
        I18n.locale || I18n.default_locale
      end

      def _fortitude_override_locale!(locale, &block)
        old_locale = I18n.locale
        I18n.locale = locale
        begin
          _fortitude_override_widget_locale_method!(locale, &block)
        ensure
          I18n.locale = old_locale
        end
      end

      module ClassMethods

      end
    end
  end
end
