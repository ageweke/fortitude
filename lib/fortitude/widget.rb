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

        rebuild_assign_locals_from! if names.length > 0

        @needs
      end

      def get_needs
        @needs || { }
      end

      def rebuild_assign_locals_from!
        ivar_prefix = assign_instance_variable_prefix

        method = <<-EOS
  def assign_locals_from(assigns)
    the_needs = self.class.get_needs
    missing = [ ]
    have_missing = false

EOS
        (@needs || { }).each do |need, default_value|
          method << <<-EOS
    # Need '#{need}', default value #{default_value.inspect}
    value = assigns[:#{need}]

    if (! value) && (! assigns.has_key?(:#{need}))
      s = '#{need}'.freeze
      value = assigns[s]
      if (! value) && (! assigns.has_key?(s))
        value = the_needs[:#{need}]

        if value == REQUIRED_NEED
          missing << :#{need}
          have_missing = true
        end
      end
    end

    @#{ivar_prefix}#{need} = value

EOS
        end

        method << <<-EOS

    raise Fortitude::Errors::MissingNeed.new(self, missing, assigns) if have_missing
  end
EOS

        $stderr.puts "RUNNING: #{method}"
        class_eval(method)
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

    def assigns
      @_fortitude_all_assigns
    end

=begin
    def assign_locals_from(assigns)
      needs = self.class.needs
      prefix = "@#{self.class.assign_instance_variable_prefix}"

      missing = [ ]

      needs.each do |name, default_value|
        ivar_name = "#{prefix}#{name}"

        # symbol
        value = assigns[name]
        if value || assigns.has_key?(name)
          instance_variable_set(ivar_name, value)
        else
          name = name.to_s
          value = assigns[name]
          if value || assigns.has_key?(name)
            instance_variable_set(ivar_name, value)
          elsif default_value == REQUIRED_NEED
            missing << name.to_sym
          else
            instance_variable_set(ivar_name, default_value)
          end
        end
      end

      raise Fortitude::Errors::MissingNeed.new(self, missing, assigns) if missing.length > 0
    end

    def assign_locals_from(assigns)
      needs = self.class.needs
      extra_assigns = self.class.extra_assigns
      prefix = self.class.assign_instance_variable_prefix

      extra = { }
      net_assign_set = { }

      assigns.each do |name, value|
        name = name.to_sym
        has_need = needs.has_key?(name)
        default_value = needs[name]

        if has_need || extra_assigns == :use
          instance_variable_set("@#{prefix}#{name}", value)
          net_assign_set[name] = value
        else
          extra[name] = value
        end
      end

      raise Fortitude::Errors::ExtraAssigns.new(self, extra) if extra.size > 0 && extra_assigns == :error

      missing = [ ]

      needs.each do |name, default_value|
        if (! assigns.has_key?(name))
          if default_value != REQUIRED_NEED
            instance_variable_set("@#{prefix}#{name}", default_value)
            net_assign_set[name] = default_value
          else
            missing << name
          end
        end
      end

      raise Fortitude::Errors::MissingNeed.new(self, missing, assigns) if missing.length > 0

      @_fortitude_all_assigns = net_assign_set.with_indifferent_access.freeze
    end
=end

    def content
      raise "Must override in #{self.class.name}"
    end

    def method_missing(name, *args, &block)
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
          rebuild_assign_locals_from!
        end
      end

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
    extra_assigns :error

    rebuild_run_content!
    rebuild_assign_locals_from!

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
