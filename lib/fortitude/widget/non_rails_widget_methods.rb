require 'active_support'

module Fortitude
  class Widget
    module NonRailsWidgetMethods
      extend ActiveSupport::Concern

      def widget_locale
        nil
      end
    end
  end
end
