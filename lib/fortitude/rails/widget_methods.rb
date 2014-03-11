require 'active_support'

module Fortitude
  module Rails
    module WidgetMethods
      extend ActiveSupport::Concern

      def widget_locale
        I18n.locale || I18n.default_locale
      end

      module ClassMethods

      end
    end
  end
end
