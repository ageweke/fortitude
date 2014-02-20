require 'fortitude/tag'
require 'fortitude/errors'
require 'active_support/core_ext/hash'
require 'stringio'

module Fortitude
  # TODO: rename all non-interface methods as _fortitude_*
  class Widget
    REQUIRED_NEED = Object.new
    NOT_PRESENT_NEED = Object.new

    if defined?(::Rails)
      include Fortitude::Rails::WidgetMethods
    else
      include Fortitude::NonRailsWidgetMethods
    end

    class << self
      def tag(name, options = { })
        @_this_class_tags ||= { }
        new_tag = Fortitude::Tag.new(name, options)
        @_this_class_tags[name] = new_tag
        rebuild_tag_methods!(name)
      end

      def this_class_tags
        @_this_class_tags || { }
      end

      def compute_all_tags
        out = { }
        out.merge!(superclass.compute_all_tags) if superclass.respond_to?(:compute_all_tags)
        out.merge!(this_class_tags)
        out
      end

      def all_tags
        @_all_tags ||= compute_all_tags
      end

      def get_tag(name)
        all_tags[name] || raise("no such tag: #{name.inspect}")
      end

      def rebuild_tag_methods!(which_tags_in = nil)
        which_tags = which_tags_in

        @_all_tags = compute_all_tags
        which_tags ||= @_all_tags.keys
        which_tags = Array(which_tags)
        which_tags.each do |name|
          tag = @_all_tags[name]
          raise "No tag #{name.inspect}? Have: #{@_all_tags.keys.inspect}" unless tag
          tag.define_method_on!(tags_module, :enable_formatting => self.format_output, :enforce_element_nesting_rules => self.enforce_element_nesting_rules, :enforce_attribute_rules => self.enforce_attribute_rules)
        end

        @_all_tags = compute_all_tags

        direct_subclasses.each { |s| s.rebuild_tag_methods!(which_tags_in) }
      end

      def needs(*names)
        return needs_as_hash if names.length == 0

        @this_class_needs ||= { }

        with_defaults = { }
        with_defaults = names.pop if names[-1] && names[-1].kind_of?(Hash)

        names.each do |name|
          name = name.to_s.strip.downcase.to_sym
          @this_class_needs[name] = REQUIRED_NEED
        end

        with_defaults.each do |name, default_value|
          name = name.to_s.strip.downcase.to_sym
          @this_class_needs[name] = default_value
        end

        rebuild_needs_methods!

        needs_as_hash
      end

      # EFFECTIVELY PRIVATE
      def needs_as_hash
        out = { }
        out = superclass.needs_as_hash if superclass.respond_to?(:needs_as_hash)
        out.merge(@this_class_needs || { })
      end

      # EFFECTIVELY PRIVATE
      def rebuild_needs_methods!
        rebuild_my_needs_methods!
        direct_subclasses.each { |s| s.rebuild_needs_methods! }
      end

      private
      def rebuild_my_needs_methods!
        n = needs_as_hash
        ivar_prefix = assign_instance_variable_prefix

        method_text = StringIO.new

        method_text.puts "  def assign_locals_from(assigns)"
        method_text.puts "    @_fortitude_raw_assigns = assigns"
        method_text.puts "    the_needs = self.class.needs_as_hash"
        method_text.puts "    missing = [ ]"
        method_text.puts "    have_missing = false"

        if [ :error, :use ].include?(extra_assigns)
          method_text.puts "    @_fortitude_extra_assigns = assigns.symbolize_keys"
        end

        n.each do |need, default_value|
          method_text.puts "    # Need '#{need}' -------------------------------------------------"
          if [ :error, :use ].include?(extra_assigns)
            method_text.puts "    @_fortitude_extra_assigns.delete(:#{need})"
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
          method_text.puts "    raise Fortitude::Errors::ExtraAssigns.new(self, @_fortitude_extra_assigns) if @_fortitude_extra_assigns.size > 0"
        elsif extra_assigns == :use
          method_text.puts "    @_fortitude_extra_assigns.each do |key, value|"
          method_text.puts "      instance_variable_set(\"@#{ivar_prefix}\#{key}\", value)"
          method_text.puts "    end"
        end

        method_text.puts "    raise Fortitude::Errors::MissingNeed.new(self, missing, assigns) if have_missing"
        method_text.puts "  end"

        class_eval(method_text.string)

        n.each do |need, default_value|
          class_eval(<<-EOS)
  def #{need}
    @#{ivar_prefix}#{need}
  end
EOS
        end
      end

      def direct_subclasses
        @direct_subclasses || [ ]
      end

      def inherited(subclass)
        @direct_subclasses ||= [ ]
        @direct_subclasses |= [ subclass ]
      end

      def tags_module
        @tags_module ||= begin
          out = Module.new
          include(out)
          out
        end
      end
    end

    def initialize(assigns = { })
      assign_locals_from(assigns)
    end

    class AssignsProxy
      def initialize(widget, keys)
        @widget = widget
        @keys = { }
        keys.each { |k| @keys[k] = true }
        @ivar_prefix = "@#{widget.class.assign_instance_variable_prefix}"
      end

      def keys
        @keys.keys
      end

      def has_key?(x)
        !! @keys[x.to_sym]
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
        "<Assigns for #{@widget}: #{to_hash}>"
      end

      def inspect
        "<Assigns for #{@widget}: #{to_hash.inspect}>"
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
        keys = self.class.needs_as_hash.keys
        keys |= (@_fortitude_raw_assigns.keys.map(&:to_sym)) if self.class.extra_assigns == :use

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

      if self.class.automatic_helper_access && @_fortitude_rendering_context && @_fortitude_rendering_context.helpers_object && @_fortitude_rendering_context.helpers_object.respond_to?(name, true)
        @_fortitude_rendering_context.helpers_object.send(name, *args, &block)
      else
        super(name, *args, &block)
      end
    end

    def widget_extra_assigns
      (@_fortitude_extra_assigns || { })
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
        needs_as_hash.keys.each do |name|
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
        else
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

      def format_output(state = nil)
        if state == nil
          return (@_fortitude_format_output == :yes) if @_fortitude_format_output
          return superclass.format_output if superclass.respond_to?(:format_output)
          false
        else
          @_fortitude_format_output = state ? :yes : :no
          rebuild_text_methods!
          rebuild_tag_methods!
        end
      end

      def enforce_element_nesting_rules(state = nil)
        if state == nil
          return (@_fortitude_enforce_element_nesting_rules == :yes) if @_fortitude_enforce_element_nesting_rules
          return superclass.enforce_element_nesting_rules if superclass.respond_to?(:enforce_element_nesting_rules)
          false
        else
          @_fortitude_enforce_element_nesting_rules = state ? :yes : :no
          rebuild_tag_methods!
        end
      end

      def enforce_attribute_rules(state = nil)
        if state == nil
          return (@_fortitude_enforce_attribute_rules == :yes) if @_fortitude_enforce_attribute_rules
          return superclass.enforce_attribute_rules if superclass.respond_to?(:enforce_attribute_rules)
          false
        else
          @_fortitude_enforce_attribute_rules = state ? :yes : :no
          rebuild_tag_methods!
        end
      end

      def use_instance_variables_for_assigns(on_or_off = nil)
        if on_or_off == nil
          return (@_fortitude_use_instance_variables_for_assigns == :yes) if @_fortitude_use_instance_variables_for_assigns
          return superclass.use_instance_variables_for_assigns if superclass.respond_to?(:use_instance_variables_for_assigns)
          false
        else
          @_fortitude_use_instance_variables_for_assigns = on_or_off ? :yes : :no
          rebuild_needs_methods!
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

      def helper(*args)
        options = args.extract_options!
        options.assert_valid_keys(:transform, :call)

        args.each do |name|
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
          when :none, nil, false then nil
          else raise ArgumentError, "Invalid value for :transform: #{transform.inspect}"
          end

          text = <<-EOS
    def #{name}(*args, &block)
      #{prefix}(@_fortitude_rendering_context.helpers_object.#{source_method_name}(*args, &block))#{suffix}
    end
EOS

          class_eval text
        end
      end

      def method_added(method_name)
        super(method_name)
        check_localized_methods!
      end

      def method_removed(method_name)
        super(method_name)
        check_localized_methods!
      end

      def include(*args)
        super(*args)
        check_localized_methods!
      end

      LOCALIZED_CONTENT_PREFIX = "localized_content_"

      def check_localized_methods!
        currently_has = instance_methods(true).detect { |i| i =~ /^#{LOCALIZED_CONTENT_PREFIX}/i }
        if currently_has != @last_localized_methods_check_has
          @last_localized_methods_check_has = currently_has
          rebuild_run_content!
        end
        direct_subclasses.each { |s| s.check_localized_methods! }
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

        if has_localized_content_methods?
          text += "  " + ("  " * acm.length) + "the_locale = widget_locale\n"
          text += "  " + ("  " * acm.length) + "locale_method_name = \"localized_content_\#{the_locale}\" if the_locale\n"
          text += "  " + ("  " * acm.length) + "if locale_method_name && respond_to?(locale_method_name)\n"
          text += "  " + ("  " * acm.length) + "  send(locale_method_name, *args, &block)\n"
          text += "  " + ("  " * acm.length) + "else\n"
          text += "  " + ("  " * acm.length) + "  content(*args, &block)\n"
          text += "  " + ("  " * acm.length) + "end\n"
        else
          text += "  " + ("  " * acm.length) + "content(*args, &block)\n"
        end

        (0..(acm.length - 1)).each do |index|
          text += "  " + ("  " * (acm.length - (index + 1))) + "end\n"
        end
        text += "end"

        class_eval(text)

        direct_subclasses.each { |s| s.rebuild_run_content! }
      end

      def rebuild_text_methods!
        text = <<-EOS
  def text(s)
EOS

        if format_output
          text << <<-EOS
    @_fortitude_rendering_context.about_to_output_non_whitespace!
EOS
        end

        text << <<-EOS
    s.to_s.fortitude_append_escaped_string(@_fortitude_output_buffer_holder.output_buffer)
  end
EOS

        class_eval(text)

        text = <<-EOS
  def rawtext(s)
EOS

        if format_output
          text << <<-EOS
    @_fortitude_rendering_context.about_to_output_non_whitespace!
EOS
        end

        text << <<-EOS
    @_fortitude_output_buffer_holder.output_buffer.original_concat(s)
  end
EOS

        class_eval(text)

        direct_subclasses.each { |s| s.rebuild_text_methods! }
      end

      private
      def this_class_around_content_methods
        @_fortitude_around_content_methods ||= [ ]
      end

      def has_localized_content_methods?
        !! (instance_methods(true).detect { |i| i =~ /^#{LOCALIZED_CONTENT_PREFIX}/i })
      end
    end

    automatic_helper_access true
    extra_assigns :ignore
    format_output false
    enforce_element_nesting_rules false
    enforce_attribute_rules false

    rebuild_run_content!
    rebuild_needs_methods!
    rebuild_text_methods!

    helper :capture
    helper :form_tag, :transform => :output_return_value
    helper :render, :transform => :output_return_value

    tag :html, :newline_before => true
    tag :body, :newline_before => true
    tag :head, :newline_before => true
    tag :link, :newline_before => true
    tag :style, :newline_before => true

    tag :header, :newline_before => true
    tag :nav, :newline_before => true
    tag :section, :newline_before => true
    tag :footer, :newline_before => true

    tag :script, :newline_before => true
    tag :meta, :newline_before => true
    tag :title, :newline_before => true

    tag :h1, :newline_before => true
    tag :h2, :newline_before => true
    tag :h3, :newline_before => true
    tag :h4, :newline_before => true
    tag :h5, :newline_before => true
    tag :h6, :newline_before => true

    tag :div, :newline_before => true
    tag :span

    tag :ul, :newline_before => true
    tag :ol, :newline_before => true
    tag :li, :newline_before => true

    tag :p, :newline_before => true, :can_enclose => [ :b ], :valid_attributes => %w{class id}

    tag :a
    tag :img

    tag :form, :newline_before => true
    tag :input, :newline_before => true
    tag :submit, :newline_before => true
    tag :button, :newline_before => true
    tag :label, :newline_before => true
    tag :select, :newline_before => true
    tag :optgroup, :newline_before => true
    tag :option, :newline_before => true
    tag :textarea, :newline_before => true
    tag :fieldset, :newline_before => true

    tag :table, :newline_before => true
    tag :tr, :newline_before => true
    tag :th, :newline_before => true
    tag :td, :newline_before => true

    tag :time

    tag :i
    tag :b
    tag :em
    tag :strong

    tag :br
    tag :hr, :newline_before => true

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

    def ttext(key, *args)
      text t(".#{key}", *args)
    end

    def output_buffer
      @_fortitude_output_buffer_holder.output_buffer
    end

    def shared_variables
      @_fortitude_rendering_context.instance_variable_set
    end

    def capture(&block)
      helpers = @_fortitude_rendering_context.helpers_object
      if helpers && helpers.respond_to?(:capture, true) &&
        [ 0, -1].include?(helpers.method(:capture).arity)
        helpers.capture(&block)
      else
        _fortitude_builtin_capture(&block)
      end
    end

    private
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

    def _fortitude_new_buffer
      _fortitude_class_for_new_buffer.new
    end

    POTENTIAL_NEW_BUFFER_CLASSES = %w{ActionView::OutputBuffer ActiveSupport::SafeBuffer String}

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
  end
end
