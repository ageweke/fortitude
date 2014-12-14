require 'active_support/concern'

module Fortitude
  module Rails
    module FortitudeRailsHelpers
      extend ActiveSupport::Concern

      EMPTY_RETURN_VALUE = ''.html_safe.freeze

      def widget(target, assigns = {}, options = {}, &block)
        if target.kind_of?(Class) && ((target < ::Fortitude::Widget) || ::Fortitude::Erector.is_erector_widget_class?(target))
          assigns ||= { }
          target = target.new(assigns)
        end

        if target.kind_of?(::Fortitude::Widget)
          rendering_context = ::Fortitude::RenderingContext.new(:delegate_object => self)
          target.render_to(rendering_context, &block)
        elsif ::Fortitude::Erector.is_erector_widget?(target)
          target.send(:_emit,
            :parent => self,
            :helpers => self,
            :output => output_buffer)
        else
          raise TypeError, "You must pass a Fortitude or Erector widget, or widget class, to #widget; you passed: #{target.inspect}"
        end

        EMPTY_RETURN_VALUE
      end
    end
  end
end
