require 'active_support'
require 'active_support/concern'

require 'fortitude/tags/partial_tag_placeholder'

module Fortitude
  class Widget
    module Rendering
      extend ActiveSupport::Concern

      # PUBLIC API
      def render(*args, &block)
        call_through = lambda do
          @_fortitude_rendering_context.record_render(args) do
            tag_rawtext(invoke_helper(:render, *args, &block))
          end
        end

        if self.class._fortitude_record_emitting_tag? && args[0].kind_of?(Hash) && args[0].has_key?(:partial)
          @_fortitude_rendering_context.emitting_tag!(self, Fortitude::Tags::PartialTagPlaceholder.instance, nil, nil, &call_through)
        else
          call_through.call
        end
      end

      def render_to(rendering_context, &block_for_content_method)
        @_fortitude_rendering_context = rendering_context
        @_fortitude_output_buffer_holder = rendering_context.output_buffer_holder
        @_fortitude_block_for_content_method = block_for_content_method

        block = lambda { |*args| yield_from_widget(*args) }

        rendering_context.record_widget(self) do
          begin
            run_content(&block)
          ensure
            @_fortitude_rendering_context = nil
            @_fortitude_block_for_content_method = nil
          end
        end
      end

      # PUBLIC API
      def to_html(rendering_context = ::Fortitude::RenderingContext.new({ }))
        render_to(rendering_context)
        rendering_context.output_buffer_holder.output_buffer
      end

      # PUBLIC API
      def rendering_context
        @_fortitude_rendering_context
      end

      # PUBLIC API
      def widget(w, hash = nil, &block)
        if w.kind_of?(Class) && ((w < ::Fortitude::Widget) || ::Fortitude::Erector.is_erector_widget_class?(w))
          hash ||= { }
          w = w.new(hash)
        end

        if w.kind_of?(::Fortitude::Widget)
          w.render_to(@_fortitude_rendering_context, &block)
        elsif ::Fortitude::Erector.is_erector_widget?(w)
          w.send(:_emit,
            :parent => rendering_context.helpers_object,
            :helpers => rendering_context.helpers_object,
            :output => rendering_context.output_buffer_holder.output_buffer)
        else
          raise "You tried to render a widget, but this is not valid: #{w.inspect}(#{hash.inspect})"
        end
      end

      # PUBLIC API
      def output_buffer
        @_fortitude_output_buffer_holder.output_buffer
      end

      # PUBLIC API
      def initialize(assigns = { }, &block)
        assign_locals_from(assigns)
        @_fortitude_constructor_block = block
      end

      # INTERNAL USE ONLY
      def _fortitude_new_buffer
        _fortitude_class_for_new_buffer.new
      end
      private :_fortitude_new_buffer

      POTENTIAL_NEW_BUFFER_CLASSES = %w{ActionView::OutputBuffer ActiveSupport::SafeBuffer String}

      # INTERNAL USE ONLY
      def _fortitude_class_for_new_buffer
        @_fortitude_class_for_new_buffer ||= begin
          out = nil
          POTENTIAL_NEW_BUFFER_CLASSES.each do |class_name|
            klass = eval(class_name) rescue nil
            if klass
              out = klass
              break
            end
          end
          raise "Huh? NONE of the following classes appear to be defined?!? #{POTENTIAL_NEW_BUFFER_CLASSES.inspect}" unless out
          out
        end
      end
      private :_fortitude_class_for_new_buffer

      def _fortitude_yield_from_widget(*args)
        if @_fortitude_block_for_content_method
          @_fortitude_block_for_content_method.call(*args)
        elsif @_fortitude_constructor_block
          @_fortitude_constructor_block.call(*args)
        else
          @_fortitude_rendering_context.yield_from_widget(*args)
        end
      end

      # PUBLIC API
      def yield_from_widget(*args)
        _fortitude_yield_from_widget(self, *args)
      end

      # PUBLIC API (Erector compatibility)
      def call_block
        _fortitude_yield_from_widget
      end
    end
  end
end
