require 'fortitude/instance_variable_set'

module Fortitude
  class RenderingContext
    attr_reader :output_buffer_holder, :instance_variable_set, :helpers_object

    def initialize(options)
      options.assert_valid_keys(:delegate_object, :output_buffer_holder, :helpers_object, :instance_variables_object, :yield_block)

      @output_buffer_holder = options[:output_buffer_holder]
      if (! @output_buffer_holder) && options[:delegate_object] && options[:delegate_object].respond_to?(:output_buffer)
        @output_buffer_holder = options[:delegate_object]
      end
      @output_buffer_holder ||= OutputBufferHolder.new
      @helpers_object = options[:helpers_object] || options[:delegate_object] || Object.new

      instance_variables_object = options[:instance_variables_object] || options[:delegate_object] || Object.new
      @instance_variable_set = Fortitude::InstanceVariableSet.new(instance_variables_object)

      @indent = 0
      @newline_needed = false
      @have_output = false
      @current_element_nesting = [ ]

      @current_widget_nesting = [ ]
      @all_widgets = [ ]

      @yield_block = options[:yield_block]
    end

    def record_tag(widget, tag_object)
      validate_element_for_rules(widget, tag_object)
      @current_element_nesting << tag_object

      begin
        yield
      ensure
        last = @current_element_nesting.pop
        unless last == tag_object
          raise "Something horrible happened -- the last tag we started was #{last}, but now we're ending #{tag_object}?!?"
        end
      end
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

    def about_to_output_non_whitespace!
      if @newline_needed
        if @have_output
          o = @output_buffer_holder.output_buffer
          o.original_concat(NEWLINE)
          o.original_concat("  " * @indent)
        end

        @newline_needed = false
      end

      @have_output = true
    end

    NEWLINE = "\n"

    def yield_to_view(*args)
      raise "No layout to yield to!" unless @yield_block
      @output_buffer_holder.output_buffer << @yield_block.call(*args)
    end

    def flush!
      # nothing here right now
    end

    private
    def validate_element_for_rules(widget, tag_object)
      current = @current_element_nesting[-1]
      current.validate_can_enclose!(widget, tag_object) if current
    end

    class OutputBufferHolder
      attr_accessor :output_buffer

      def initialize
        if defined?(::ActionView::OutputBuffer)
          @output_buffer = ::ActionView::OutputBuffer.new
        else
          @output_buffer = ""
        end

        @output_buffer.force_encoding(Encoding::UTF_8)
      end
    end
  end
end
