require 'fortitude/support/instance_variable_set'
require 'fortitude/tags/render_widget_placeholder'

module Fortitude
  class RenderingContext
    attr_reader :output_buffer_holder, :instance_variable_set, :helpers_object

    class << self
      def default_rendering_context
        new({ })
      end
    end

    def initialize(options)
      options.assert_valid_keys(:delegate_object, :output_buffer_holder, :helpers_object, :instance_variables_object,
        :yield_block, :render_yield_result)

      @output_buffer_holder = options[:output_buffer_holder]
      if (! @output_buffer_holder) && options[:delegate_object] && options[:delegate_object].respond_to?(:output_buffer)
        @output_buffer_holder = options[:delegate_object]
      end
      @output_buffer_holder ||= OutputBufferHolder.new
      @helpers_object = options[:helpers_object] || options[:delegate_object] || Object.new

      instance_variables_object = options[:instance_variables_object] || options[:delegate_object] || Object.new
      @instance_variable_set = Fortitude::Support::InstanceVariableSet.new(instance_variables_object)

      @render_yield_result = true unless options.has_key?(:render_yield_result) && (! options[:render_yield_result])

      @indent = 0
      @newline_needed = false
      @have_output = false
      @indenting_disabled = false

      @current_element_nesting = [ ]
      @current_widget_nesting = [ ]
      @ids_used = { }

      @yield_block = options[:yield_block]
    end

    def with_element_nesting_validation(value)
      old_value = @element_nesting_validation_disabled
      @element_nesting_validation_disabled = !value
      begin
        yield
      ensure
        @element_nesting_validation_disabled = old_value
      end
    end

    def with_attribute_validation(value)
      old_value = @attribute_validation_disabled
      @attribute_validation_disabled = !value
      begin
        yield
      ensure
        @attribute_validation_disabled = old_value
      end
    end

    def with_id_uniqueness(value)
      old_value = @id_uniqueness_disabled
      @id_uniqueness_disabled = !value
      begin
        yield
      ensure
        @id_uniqueness_disabled = old_value
      end
    end

    def attribute_validation_disabled?
      !! @attribute_validation_disabled
    end

    def record_render(args, &block)
      record_widget(::Fortitude::Tags::RenderWidgetPlaceholder.new(args), &block)
    end

    def record_widget(widget)
      start_widget!(widget)
      @current_widget_nesting << widget
      @current_element_nesting << widget
      begin
        yield
      ensure
        last = @current_widget_nesting.pop
        unless last.equal?(widget)
          raise "Something horrible happened -- the last widget we started was #{last}, but now we're ending #{widget}?!?"
        end
        last = @current_element_nesting.pop
        unless last.equal?(widget)
          raise "Something horrible happened -- the last element we started was #{last}, but now we're ending #{widget}?!?"
        end
        end_widget!(widget)
      end
    end

    def start_widget!(widget)
      # nothing here
    end

    def end_widget!(widget)
      # nothing here
    end

    def current_widget_depth
      @current_widget_nesting.length - 1
    end

    def parent_widget
      @current_widget_nesting[-2]
    end

    def emitting_tag!(widget, tag_object, content_or_attributes, attributes)
      validate_element_for_rules(widget, tag_object) if widget.class.enforce_element_nesting_rules
      @current_element_nesting << tag_object

      begin
        yield
      ensure
        last = @current_element_nesting.pop
        unless last.equal?(tag_object)
          raise "Something horrible happened -- the last tag we started was #{last}, but now we're ending #{tag_object}?!?"
        end
      end
    end

    def current_element_nesting
      @current_element_nesting
    end

    def format_output?
      true
    end

    def increase_indent!
      @indent += 1
    end

    def decrease_indent!
      @indent -= 1
    end

    def needs_newline!
      @newline_needed = true
    end

    def suppress_formatting!
      @suppress_formatting_level ||= 0
      @suppress_formatting_level += 1
    end

    def desuppress_formatting!
      @suppress_formatting_level -= 1
    end

    def current_indent
      ("  " * @indent).freeze
    end

    def with_indenting_disabled
      old_indenting_disabled = @indenting_disabled
      @indenting_disabled = true
      begin
        yield
      ensure
        @indenting_disabled = old_indenting_disabled
      end
    end

    def about_to_output_non_whitespace!
      if @newline_needed && ((@suppress_formatting_level ||= 0) == 0)
        if @have_output
          o = @output_buffer_holder.output_buffer
          o.original_concat(NEWLINE)
          o.original_concat(current_indent) unless @indenting_disabled
        end

        @newline_needed = false
      end

      @have_output = true
    end

    def with_yield_block(new_yield_block)
      old_yield_block, @yield_block = @yield_block, new_yield_block
      begin
        yield
      ensure
        @yield_block = old_yield_block
      end
    end

    NEWLINE = "\n"

    def effective_yield_block
      if @yield_block
        lambda do |*args|
          result = @yield_block.call(*args)
          @output_buffer_holder.output_buffer << result if @render_yield_result
          result
        end
      end
    end

    def flush!
      # nothing here right now
    end

    def validate_id_uniqueness(widget, tag_name, id)
      id = id.to_s
      if @ids_used[id] && (! @id_uniqueness_disabled)
        (already_used_widget, already_used_tag_name) = @ids_used[id]
        raise Fortitude::Errors::DuplicateId.new(widget, id, already_used_widget, already_used_tag_name, tag_name)
      else
        @ids_used[id] = [ widget, tag_name ]
      end
    end

    private
    def validate_element_for_rules(widget, tag_object)
      current = @current_element_nesting[-1]
      current.validate_can_enclose!(widget, tag_object) if current && (! @element_nesting_validation_disabled)
    end

    class OutputBufferHolder
      attr_accessor :output_buffer

      def initialize
        if defined?(::ActionView::OutputBuffer)
          @output_buffer = ::ActionView::OutputBuffer.new
        else
          @output_buffer = ::ActiveSupport::SafeBuffer.new
        end

        @output_buffer.force_encoding(Encoding::UTF_8) if @output_buffer.respond_to?(:force_encoding)
      end
    end
  end
end
