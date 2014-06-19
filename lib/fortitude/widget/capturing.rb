require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module Capturing
      extend ActiveSupport::Concern

      # PUBLIC API
      def capture(&block)
        helpers = @_fortitude_rendering_context.helpers_object
        if helpers && helpers.respond_to?(:capture, true) &&
          [ 0, -1 ].include?(helpers.method(:capture).arity)
          helpers.capture(&block)
        else
          _fortitude_builtin_capture(&block)
        end
      end

      # INTERNAL USE ONLY
      def _fortitude_builtin_capture(&block)
        old_buffer = nil
        new_buffer = nil
        begin
          new_buffer = _fortitude_new_buffer
          old_buffer, @_fortitude_output_buffer_holder.output_buffer = @_fortitude_output_buffer_holder.output_buffer, new_buffer
          _fortitude_new_buffer.force_encoding(old_buffer.encoding) if old_buffer && old_buffer.respond_to?(:encoding)
          block.call
          new_buffer
        ensure
          @_fortitude_output_buffer_holder.output_buffer = old_buffer
        end
      end
      private :_fortitude_builtin_capture
    end
  end
end
