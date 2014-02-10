require 'fortitude/tag'
require 'fortitude/errors'
require 'active_support/core_ext/hash'

module Fortitude
  class Widget
    REQUIRED_NEED = Object.new

    class << self
      def tags_module
        @tags_module ||= begin
          out = Module.new
          include(out)
          out
        end
      end

      def tag(name, options = { })
        Fortitude::Tag.new(name, options).define_method_on!(tags_module)
      end

      def needs(*names)
        @needs ||= { }

        with_defaults = { }
        with_defaults = names.pop if names[-1] && names[-1].kind_of?(Hash)

        names.each do |name|
          name = name.to_s.strip.downcase.to_sym
          @needs[name] = REQUIRED_NEED
        end

        with_defaults.each do |name, default_value|
          name = name.to_s.strip.downcase.to_sym
          @needs[name] = default_value
        end

        @needs.keys.each do |n|
          class_eval <<-EOS
  def #{n}
    @_fortitude_assign_#{n}
  end
EOS
        end

        @needs
      end
    end

    tag :html
    tag :body
    tag :head
    tag :link
    tag :style

    tag :header
    tag :nav
    tag :section
    tag :footer

    tag :script
    tag :meta
    tag :title

    tag :h1
    tag :h2
    tag :h3
    tag :h4
    tag :h5
    tag :h6

    tag :div
    tag :span

    tag :ul
    tag :ol
    tag :li

    tag :p

    tag :a
    tag :img

    tag :form
    tag :input
    tag :submit
    tag :button
    tag :label
    tag :select
    tag :optgroup
    tag :option
    tag :textarea
    tag :fieldset

    tag :table
    tag :tr
    tag :th
    tag :td

    tag :time

    tag :i
    tag :b
    tag :em
    tag :strong

    tag :br
    tag :hr

    def initialize(assigns = { })
      assign_locals_from(assigns)
    end

    def assign_locals_from(assigns)
      missing = [ ]

      self.class.needs.each do |name, default_value|
        if assigns.has_key?(name)
          instance_variable_set("@_fortitude_assign_#{name}", assigns[name])
        elsif default_value != REQUIRED_NEED
          instance_variable_set("@_fortitude_assign_#{name}", default_value)
        else
          missing << name
        end
      end

      if missing.length > 0
        raise Fortitude::Errors::MissingNeed.new(self, missing, assigns.keys)
      end
    end

    def content
      raise "Must override in #{self.class.name}"
    end

    def method_missing(name, *args, &block)
      if self.class.automatic_helper_access && @_fortitude_rendering_context.helpers_object && @_fortitude_rendering_context.helpers_object.respond_to?(name)
        @_fortitude_rendering_context.helpers_object.send(name, *args, &block)
      else
        super(name, *args, &block)
      end
    end

    BEFORE_ATTRIBUTE_STRING = " ".freeze
    AFTER_ATTRIBUTE_STRING = "=\"".freeze
    AFTER_VALUE_STRING = "\"".freeze

    def _attributes(h)
      o = @_fortitude_output_buffer_holder.output_buffer

      h.each do |k,v|
        o.concat(BEFORE_ATTRIBUTE_STRING)
        k.to_s.fortitude_append_escaped_string(o)
        o.concat(AFTER_ATTRIBUTE_STRING)
        v.to_s.fortitude_append_escaped_string(o)
        o.concat(AFTER_VALUE_STRING)
      end
    end

    def yield_to_view(*args)
      @_fortitude_rendering_context.yield_to_view(*args)
    end

    def transfer_shared_variables(*args, &block)
      if self.class.implicit_shared_variable_access
        @_fortitude_rendering_context.instance_variable_set.with_instance_variable_copying(self, *args, &block)
      else
        block.call(*args)
      end
    end

    VALID_EXTRA_ASSIGNS_VALUES = %w{error ignore use}.map { |x| x.to_sym }

    class << self
      def implicit_shared_variable_access(on_or_off = nil)
        if on_or_off == nil
          return (@_fortitude_implicit_shared_variable_access == :yes) if @_fortitude_implicit_shared_variable_access
          return superclass.implicit_shared_variable_access if superclass.respond_to?(:implicit_shared_variable_access)
          false
        elsif on_or_off
          if (! @_fortitude_implicit_shared_variable_access)
            @_fortitude_implicit_shared_variable_access = :yes
            around_content :transfer_shared_variables
          end
        else
          @_fortitude_implicit_shared_variable_access = :no
        end
      end

      def automatic_helper_access(on_or_off = nil)
        if on_or_off == nil
          return (@_fortitude_automatic_helper_access == :yes) if @_fortitude_automatic_helper_access
          return superclass.automatic_helper_access if superclass.respond_to?(:automatic_helper_access)
          false
        else on_or_off
          @_fortitude_automatic_helper_access = on_or_off ? :yes : :no
        end
      end

      def extra_assigns(state = nil)
        if state == nil
          return @_fortitude_extra_assigns if @_fortitude_extra_assigns
          return superclass.extra_assigns if superclass.respond_to?(:extra_assigns)
          :error
        elsif VALID_EXTRA_ASSIGNS_VALUES.include?(state.to_sym)
          @_fortitude_extra_assigns = state.to_sym
        else
          raise ArgumentError, "Invalid value for extra_assigns: #{@_fortitude_extra_assigns.inspect}"
        end
      end

      def around_content(*method_names)
        return if method_names.length == 0
        @_fortitude_around_content_methods ||= [ ]
        @_fortitude_around_content_methods += method_names.map { |x| x.to_s.strip.downcase.to_sym }
        rebuild_run_content!
      end

      def helper(name, options = { })
        options.assert_valid_keys(:transform, :call)

        source_method_name = options[:call] || name

        prefix = "return"
        suffix = ""
        case (transform = options[:transform])
        when :output_return_value
          prefix = "text"
          suffix = "; nil"
        when :return_output
          prefix = "return capture { "
          suffix = " }"
        when nil, false then nil
        else raise ArgumentError, "Invalid value for :transform: #{transform.inspect}"
        end

        class_eval <<-EOS
  def #{name}(*args, &block)
    #{prefix}(@_fortitude_rendering_context.helpers_object.#{source_method_name}(*args, &block))#{suffix}
  end
EOS
      end

      private
      def this_class_around_content_methods
        @_fortitude_around_content_methods ||= [ ]
      end

      def around_content_methods
        superclass_methods = if superclass.respond_to?(:around_content_methods)
          superclass.around_content_methods
        else
          [ ]
        end

        (superclass_methods + this_class_around_content_methods).uniq
      end

      def rebuild_run_content!
        acm = around_content_methods
        text = "def run_content(*args, &block)\n"
        acm.each_with_index do |method_name, index|
          text += "  " + ("  " * index) + "#{method_name}(*args) do\n"
        end
        text += "  " + ("  " * acm.length) + "content(*args, &block)\n"
        (0..(acm.length - 1)).each do |index|
          text += "  " + ("  " * (acm.length - (index + 1))) + "end\n"
        end
        text += "end"

        class_eval(text)
      end
    end

    rebuild_run_content!
    automatic_helper_access true
    extra_assigns :error

    helper :capture
    helper :form_tag, :transform => :output_return_value
    helper :render, :transform => :output_return_value

    def to_html(rendering_context)
      @_fortitude_rendering_context = rendering_context
      @_fortitude_output_buffer_holder = rendering_context.output_buffer_holder

      block = lambda { |*args| @_fortitude_rendering_context.yield_to_view(*args) }

      begin
        run_content(&block)
      ensure
        @_fortitude_rendering_context = nil
      end
    end

    def widget(w)
      w.to_html(@_fortitude_rendering_context)
    end

    def text(s)
      s.to_s.fortitude_append_escaped_string(@_fortitude_output_buffer_holder.output_buffer)
    end

    def rawtext(s)
      @_fortitude_output_buffer_holder.output_buffer.original_concat(s)
    end

    def output_buffer
      @_fortitude_output_buffer_holder.output_buffer
    end

    def shared_variables
      @_fortitude_rendering_context.instance_variable_set
    end
  end
end
