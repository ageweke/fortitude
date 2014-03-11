require 'active_support'

module Fortitude
  module NonRailsWidgetMethods
    extend ActiveSupport::Concern

    def widget_locale
      nil
    end

    module ClassMethods
      def static_method_helpers_object(widget)
        nil
      end
    end
  end
end
