require 'fortitude/tag'
require 'fortitude/errors'
require 'active_support/core_ext/hash'
require 'stringio'

module Fortitude
  class Widget
    REQUIRED_NEED = Object.new
    NOT_PRESENT_NEED = Object.new

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
        return get_needs if names.length == 0

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

        rebuild_needs_methods!

        @needs
      end

      def get_needs
        @needs || { }
      end

      def rebuild_needs_methods!
        n = get_needs
        ivar_prefix = assign_instance_variable_prefix

        method_text = StringIO.new

        method_text.puts "  def assign_locals_from(assigns)"
        method_text.puts "    @_fortitude_raw_assigns = assigns"
        method_text.puts "    the_needs = self.class.get_needs"
        method_text.puts "    missing = [ ]"
        method_text.puts "    have_missing = false"

        if [ :error, :use ].include?(extra_assigns)
          method_text.puts "    extra = assigns.symbolize_keys"
        end

        n.each do |need, default_value|
          method_text.puts "    # Need '#{need}' -------------------------------------------------"
          if [ :error, :use ].include?(extra_assigns)
            method_text.puts "    extra.delete(:#{need})"
          end

          method_text.puts "    value = assigns.fetch(:#{need}, NOT_PRESENT_NEED)"
          method_text.puts "    if value == NOT_PRESENT_NEED"
          method_text.puts "      value = assigns.fetch('#{need}', NOT_PRESENT_NEED)"
          method_text.puts "      if value == NOT_PRESENT_NEED"

          if default_value == REQUIRED_NEED
            method_text.puts "        value = nil"
            method_text.puts "        missing << :#{need}"
            method_text.puts "        have_missing = true"
          else
            method_text.puts "        value = the_needs[:#{need}]"
          end
          method_text.puts "      end"
          method_text.puts "    end"
          method_text.puts "    "
          method_text.puts "    @#{ivar_prefix}#{need} = value"
        end

        if extra_assigns == :error
          method_text.puts "    raise Fortitude::Errors::ExtraAssigns.new(self, extra) if extra.size > 0"
        elsif extra_assigns == :use
          method_text.puts "    extra.each do |key, value|"
          method_text.puts "      instance_variable_set(\"@#{ivar_prefix}\#{key}\", value)"
          method_text.puts "    end"
        end

        method_text.puts "    raise Fortitude::Errors::MissingNeed.new(self, missing, assigns) if have_missing"
        method_text.puts "  end"

        # $stderr.puts "RUNNING: #{method_text.string}"
        class_eval(method_text.string)

        n.each do |need, default_value|
          class_eval(<<-EOS)
  def #{need}
    @#{ivar_prefix}#{need}
  end
EOS
        end
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

    class AssignsProxy
      def initialize(widget, keys)
        @widget = widget
        @keys = { }
        keys.each { |k| @keys[k] = true }
        @ivar_prefix = "@#{assign_instance_variable_prefix}"
      end

      def keys
        @keys.keys
      end

      def has_key?(x)
        @keys[x.to_sym]
      end

      def [](x)
        @widget.instance_variable_get("#{@ivar_prefix}#{x}") if has_key?(x)
      end

      def []=(x, y)
        @widget.instance_variable_set("#{@ivar_prefix}#{x}", y) if has_key?(x)
      end

      def to_hash
        out = { }
        keys.each { |k| out[k] = self[k] }
        out
      end

      def to_h
        to_hash
      end

      def length
        @keys.length
      end

      def size
        @keys.size
      end

      def to_s
        "<Assigns for #{widget}: #{to_hash}>"
      end

      def inspect
        "<Assigns for #{widget}: #{to_hash.inspect}>"
      end

      def member?(x)
        has_key?(x)
      end

      def store(key, value)
        self[key] = value
      end

      delegate :==, :assoc, :each, :each_pair, :each_key, :each_value, :empty?, :eql?, :fetch, :flatten,
        :has_value?, :hash, :include?, :invert, :key, :key?, :merge, :rassoc, :reject, :select,
        :to_a, :value?, :values, :values_at, :to => :to_hash
    end

    def assigns
      @_fortitude_assigns_proxy ||= begin
        keys = get_needs.keys
        keys |= (@_fortitude_raw_assigns.keys.map(&:to_sym)) if extra_assigns == :use

        AssignsProxy.new(self, keys)
      end
    end

    def content
      raise "Must override in #{self.class.name}"
    end

    def method_missing(name, *args, &block)
      if self.class.extra_assigns == :use
        ivar_name = "@#{self.class.assign_instance_variable_prefix}#{name}"
        return instance_variable_get(ivar_name) if instance_variable_defined?(ivar_name)
      end

      if self.class.automatic_helper_access && @_fortitude_rendering_context && @_fortitude_rendering_context.helpers_object && @_fortitude_rendering_context.helpers_object.respond_to?(name)
        @_fortitude_rendering_context.helpers_object.send(name, *args, &block)
      else
        super(name, *args, &block)
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
    STANDARD_INSTANCE_VARIABLE_PREFIX = "_fortitude_assign_"

    class << self
      def extract_needed_assigns_from(input)
        input = input.with_indifferent_access

        out = { }
        get_needs.keys.each do |name|
          out[name] = input[name] if input.has_key?(name)
        end
        out
      end

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
          rebuild_needs_methods!
        else
          raise ArgumentError, "Invalid value for extra_assigns: #{@_fortitude_extra_assigns.inspect}"
        end
      end

      def use_instance_variables_for_assigns(on_or_off = nil)
        if on_or_off == nil
          return (@_fortitude_use_instance_variables_for_assigns == :yes) if @_fortitude_use_instance_variables_for_assigns
          return superclass.use_instance_variables_for_assigns if superclass.respond_to?(:use_instance_variables_for_assigns)
          false
        else on_or_off
          @_fortitude_use_instance_variables_for_assigns = on_or_off ? :yes : :no
          rebuild_needs_methods!
        end
      end

      ### ==============================
      ### TODO: Doesn't use_instance_variables_for_assigns conflict with implicit_shared_variable_access?
      ### If you pass a parameter :foo into the widget, won't it copy that back out to the controller afterwards?

      def assign_instance_variable_prefix
        use_instance_variables_for_assigns ? "" : STANDARD_INSTANCE_VARIABLE_PREFIX
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

    automatic_helper_access true
    extra_assigns :ignore

    rebuild_run_content!
    rebuild_needs_methods!

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
