require 'active_support'

module Fortitude
  module NonRailsWidgetMethods
    extend ActiveSupport::Concern

    def widget_locale
      nil
    end

    module ClassMethods

    end
  end
end
