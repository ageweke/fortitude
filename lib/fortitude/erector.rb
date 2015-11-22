module Fortitude
  module Erector
    class << self
      def is_erector_available?
        @is_erector_available ||= begin
          %w{erector-rails4 erector}.each do |gem_name|
            begin
              gem gem_name
            rescue Gem::LoadError => le
              # ok
            end
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

      def erector_widget_base_class_if_available
        ::Erector::Widget if is_erector_available?
      end

      def is_erector_widget?(widget)
        is_erector_widget_class?(widget.class)
      end
    end

    class ErectorOutputBufferHolder
      def initialize(erector_output)
        @erector_output = erector_output
      end

      def output_buffer
        erector_output.buffer
      end

      private
      attr_reader :erector_output
    end
  end
end

if ::Fortitude::Erector.is_erector_available?
  ::Erector::AbstractWidget.class_eval do
    def widget_with_fortitude(target, assigns = {}, options = {}, &block)
      if (target.kind_of?(::Class) && target < ::Fortitude::Widget)
        target = target.new(assigns)
      end

      if target.kind_of?(::Fortitude::Widget)
        rendering_context = ::Fortitude::RenderingContext.new(
          :delegate_object => parent,
          :output_buffer_holder => ::Fortitude::Erector::ErectorOutputBufferHolder.new(output),
          :helpers_object => helpers)
        return target.render_to(rendering_context, &block)
      else
        return widget_without_fortitude(target, assigns, options, &block)
      end
    end

    alias_method_chain :widget, :fortitude
  end
end
