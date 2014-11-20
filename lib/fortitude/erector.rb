module Fortitude
  module Erector
    class << self
      def is_erector_available?
        @is_erector_available ||= begin
          begin
            gem 'erector'
          rescue Gem::LoadError => le
            # ok
          end

          begin
            require 'erector'
          rescue LoadError => le
            # ok
          end

          if defined?(::Erector::Widget) then :yes else :no end
        end

        @is_erector_available == :yes
      end

      def is_erector_widget_class?(widget_class)
        return false unless is_erector_available?
        return false unless widget_class.kind_of?(::Class)
        return true if widget_class == ::Erector::Widget
        return false if widget_class == ::Object
        return is_erector_widget_class?(widget_class.superclass)
      end
    end
  end
end
