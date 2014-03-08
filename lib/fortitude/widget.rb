require 'fortitude/tag'
require 'fortitude/tags_module'
require 'fortitude/errors'
require 'fortitude/assigns_proxy'
require 'fortitude/doctypes'
require 'fortitude/partial_tag_placeholder'
require 'active_support/core_ext/hash'

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
      def _fortitude_class_inheritable_attribute(attribute_name, default_value, allowable_values)
        metaclass = (class << self; self; end)
        metaclass.send(:define_method, attribute_name) do |*args|
          raise ArgumentError, "Invalid arguments: #{args.inspect}" if args.length > 1
          instance_variable_name = "@_fortitude_#{attribute_name}"
          if args.length == 0
            return instance_variable_get(instance_variable_name) if instance_variable_defined?(instance_variable_name)
            return superclass.send(attribute_name) if superclass.respond_to?(attribute_name)
            raise "Fortitude class-inheritable attribute error: there should always be a declared value for #{attribute_name} at the top of the inheritance hierarchy somewhere"
          else
            new_value = args[0]
            allowed = if allowable_values.respond_to?(:call)
              allowable_values.call(new_value)
            else
              allowable_values.include?(new_value)
            end

            if (! allowed)
              error = "#{attribute_name} cannot be set to #{new_value.inspect}"
              error << "; valid values are: #{allowable_values.inspect}" unless allowable_values.respond_to?(:call)
              raise ArgumentError, error
            end
            instance_variable_set(instance_variable_name, new_value)
            changed_method = "_fortitude_#{attribute_name}_changed!"
            send(changed_method, new_value) if respond_to?(changed_method)
            new_value
          end
        end
        send(attribute_name, default_value)
      end
    end

    _fortitude_class_inheritable_attribute :format_output, false, [ true, false ]
    _fortitude_class_inheritable_attribute :extra_assigns, :ignore, [ :error, :ignore, :use ]
    _fortitude_class_inheritable_attribute :automatic_helper_access, true, [ true, false ]
    _fortitude_class_inheritable_attribute :implicit_shared_variable_access, false, [ true, false ]
    _fortitude_class_inheritable_attribute :enforce_element_nesting_rules, false, [ true, false ]
    _fortitude_class_inheritable_attribute :enforce_attribute_rules, false, [ true, false ]
    _fortitude_class_inheritable_attribute :use_instance_variables_for_assigns, false, [ true, false ]
    _fortitude_class_inheritable_attribute :start_and_end_comments, false, [ true, false ]
    _fortitude_class_inheritable_attribute :translation_base, nil, lambda { |s| s.kind_of?(String) || s.kind_of?(Symbol) || s == nil }

    def with_element_nesting_rules(on_or_off)
      raise ArgumentError, "We aren't even enforcing nesting rules in the first place" if on_or_off && (! self.class.enforce_element_nesting_rules)
      @_fortitude_rendering_context.with_element_nesting_validation(on_or_off) { yield }
    end

    def with_attribute_rules(on_or_off)
      raise ArgumentError, "We aren't even enforcing attribute rules in the first place" if on_or_off && (! self.class.enforce_attribute_rules)
      @_fortitude_rendering_context.with_attribute_validation(on_or_off) { yield }
    end

    class << self
      def tag(name, options = { })
        @_this_class_tags ||= { }
        new_tag = Fortitude::Tag.new(name, options)
        @_this_class_tags[name] = new_tag
        rebuild_tag_methods!(name)
      end

      def doctype(new_doctype = nil)
        if new_doctype
          new_doctype = case new_doctype
          when Fortitude::Doctypes::Base then new_doctype
          when Symbol then Fortitude::Doctypes.standard_doctype(new_doctype)
          else raise ArgumentError, "You must supply a Symbol or an instance of Fortitude::Doctypes::Base, not: #{new_doctype.inspect}"
          end

          current_doctype = doctype
          if current_doctype && new_doctype != current_doctype
            raise ArgumentError, "The doctype has already been set to #{current_doctype} on this widget class or a superclass. You can't set it to #{new_doctype}; if you want to use a different doctype, you will need to make a new subclass that has no doctype set yet."
          end

          @_fortitude_doctype = new_doctype
        else
          return @_fortitude_doctype if @_fortitude_doctype
          return superclass.doctype if superclass.respond_to?(:doctype)
          nil
        end
      end

      def this_class_tags
        @_this_class_tags || { }
      end

      def all_tags
        out = { }
        out.merge!(superclass.all_tags) if superclass.respond_to?(:all_tags)
        out.merge!(this_class_tags)
        out
      end

      def rebuild_tag_methods!(which_tags_in = nil)
        which_tags = which_tags_in

        tags = all_tags
        which_tags ||= tags.keys
        which_tags = Array(which_tags)
        which_tags.each do |name|
          tag = tags[name]
          raise "No tag #{name.inspect}? Have: #{tags.keys.inspect}" unless tag
          tag.define_method_on!(tags_module, :enable_formatting => self.format_output, :enforce_element_nesting_rules => self.enforce_element_nesting_rules, :enforce_attribute_rules => self.enforce_attribute_rules)
        end

        direct_subclasses.each { |s| s.rebuild_tag_methods!(which_tags_in) }
      end

      def is_valid_ruby_method_name?(s)
        s =~ /^[A-Za-z_][A-Za-z0-9_]*[\?\!]?$/
      end

      def needs(*names)
        previous_needs = needs_as_hash
        return previous_needs if names.length == 0

        @this_class_needs ||= { }

        with_defaults_raw = { }
        with_defaults_raw = names.pop if names[-1] && names[-1].kind_of?(Hash)
        allow_overriding = true if with_defaults_raw.delete(:fortitude_allow_overriding_methods_with_needs)

        names = names.map { |n| n.to_s.strip.downcase.to_sym }
        with_defaults = { }
        with_defaults_raw.each { |k,v| with_defaults[k.to_s.strip.downcase.to_sym] = v }

        bad_names = names.select { |n| ! is_valid_ruby_method_name?(n) }
        raise ArgumentError, "Needs in a Fortitude widget class must be valid Ruby method names; these are not: #{bad_names.inspect}" if bad_names.length > 0

        unless allow_overriding
          has_methods = names.select { |n| instance_methods(true).include?(n.to_sym) && (! previous_needs.has_key?(n)) }
          raise Fortitude::Errors::NeedConflictsWithMethod.new(self, has_methods) if has_methods.length > 0
        end

        names.each do |name|
          @this_class_needs[name] = REQUIRED_NEED
        end

        with_defaults.each do |name, default_value|
          @this_class_needs[name] = default_value
        end

        rebuild_needs!

        needs_as_hash
      end

      # EFFECTIVELY PRIVATE
      def needs_as_hash
        @_fortitude_needs_as_hash ||= begin
          out = { }
          out = superclass.needs_as_hash if superclass.respond_to?(:needs_as_hash)
          out.merge(@this_class_needs || { })
        end
      end

      # EFFECTIVELY PRIVATE
      def rebuild_needs!
        @_fortitude_needs_as_hash = nil
        rebuild_my_needs_methods!
        direct_subclasses.each { |s| s.rebuild_needs! }
      end

      private
      def rebuild_my_needs_methods!
        n = needs_as_hash

        needs_text = n.map do |need, default_value|
          Fortitude::SimpleTemplate.template('need_assignment_template').result(:extra_assigns => extra_assigns,
            :need => need, :has_default => (default_value != REQUIRED_NEED),
            :ivar_name => instance_variable_name_for(need)
          )
        end.join("\n\n")

        assign_locals_from_text = Fortitude::SimpleTemplate.template('assign_locals_from_template').result(
          :extra_assigns => extra_assigns, :needs_text => needs_text)
        class_eval(assign_locals_from_text)

        n.each do |need, default_value|
          text = Fortitude::SimpleTemplate.template('need_method_template').result(
            :need => need, :ivar_name => instance_variable_name_for(need))
          class_eval(text)
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
        @tags_module ||= Fortitude::TagsModule.new(self)
      end
    end

    def initialize(assigns = { })
      assign_locals_from(assigns)
    end

    def needs_as_hash
      @_fortitude_needs_as_hash ||= self.class.needs_as_hash
    end

    def assigns
      @_fortitude_assigns_proxy ||= begin
        keys = needs_as_hash.keys
        keys |= (@_fortitude_raw_assigns.keys.map(&:to_sym)) if self.class.extra_assigns == :use

        Fortitude::AssignsProxy.new(self, keys)
      end
    end

    def content
      raise "Must override in #{self.class.name}"
    end

    delegate :instance_variable_name_for, :to => :class

    def method_missing(name, *args, &block)
      if self.class.extra_assigns == :use
        ivar_name = self.class.instance_variable_name_for(name)
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

    MAX_START_COMMENT_VALUE_STRING_LENGTH = 100
    START_COMMENT_VALUE_STRING_TOO_LONG_ELLIPSIS = "...".freeze

    def widget_nesting_depth
      @_fortitude_widget_nesting_depth ||= @_fortitude_rendering_context.current_widget_depth
    end

    MAX_ASSIGNS_LENGTH_BEFORE_MULTIPLE_LINES = 200
    START_COMMENT_EXTRA_INDENT_FOR_NEXT_LINE = " " * 5

    def start_and_end_comments
      if self.class.start_and_end_comments
        fo = self.class.format_output

        comment_text = "BEGIN #{self.class.name} depth #{widget_nesting_depth}"

        assign_keys = assigns.keys
        if assign_keys.length > 0

          assign_text = assign_keys.map do |assign|
            value = assigns[assign]
            out = ":#{assign} => "
            out << "(DEFAULT) " if assigns.is_default?(assign)

            value_string = if value.respond_to?(:to_fortitude_comment_string) then value.to_fortitude_comment_string else value.inspect end
            if value_string.length > MAX_START_COMMENT_VALUE_STRING_LENGTH
              value_string = value_string[0..(MAX_START_COMMENT_VALUE_STRING_LENGTH - START_COMMENT_VALUE_STRING_TOO_LONG_ELLIPSIS.length)] + START_COMMENT_VALUE_STRING_TOO_LONG_ELLIPSIS
            end
            out << value_string
            out
          end

          total_length = assign_text.map(&:length).inject(0, &:+)
          if total_length > MAX_ASSIGNS_LENGTH_BEFORE_MULTIPLE_LINES
            newline_and_indent = "\n#{@_fortitude_rendering_context.current_indent}"
            newline_and_extra_indent = newline_and_indent + START_COMMENT_EXTRA_INDENT_FOR_NEXT_LINE

            comment_text << ":"
            assign_text.each do |at|
              comment_text << newline_and_extra_indent
              comment_text << at
            end
            comment_text << newline_and_indent
          else
            comment_text << ": "
            comment_text << assign_text.join(", ")
          end
        end
        comment comment_text
        yield
        comment "END #{self.class.name} depth #{widget_nesting_depth}"
      else
        yield
      end
    end

    # From http://www.w3.org/TR/html5/syntax.html#comments:
    #
    # Comments must start with the four character sequence U+003C LESS-THAN SIGN, U+0021 EXCLAMATION MARK,
    # U+002D HYPHEN-MINUS, U+002D HYPHEN-MINUS (<!--). Following this sequence, the comment may have text,
    # with the additional restriction that the text must not start with a single ">" (U+003E) character,
    # nor start with a U+002D HYPHEN-MINUS character (-) followed by a ">" (U+003E) character, nor contain
    # two consecutive U+002D HYPHEN-MINUS characters (--), nor end with a U+002D HYPHEN-MINUS character (-).
    # Finally, the comment must be ended by the three character sequence U+002D HYPHEN-MINUS, U+002D HYPHEN-MINUS,
    # U+003E GREATER-THAN SIGN (-->).
    def comment_escape(string)
      string = "_#{string}" if string =~ /^\s*(>|->)/
      string = string.gsub("--", "- - ") if string =~ /\-\-/ # don't gsub if it doesn't match to avoid generating garbage
      string = "#{string}_" if string =~ /\-\s*$/i
      string
    end

    def comment(s)
      fo = self.class.format_output
      @_fortitude_rendering_context.needs_newline! if fo
      raise ArgumentError, "You cannot pass a block to a comment" if block_given?
      rawtext "<!-- "
      rawtext comment_escape(s)
      rawtext " -->"
      @_fortitude_rendering_context.needs_newline! if fo
    end

    CDATA_START = "<![CDATA[".freeze
    CDATA_END = "]]>".freeze

    def cdata(s = nil, &block)
      if s
        raise ArgumentError, "You can only pass literal text or a block, not both" if block

        components = s.split("]]>")

        if components.length > 1
          components.each_with_index do |s, i|
            this_component = s
            this_component = ">#{this_component}" if i > 0
            this_component = "#{this_component}]]" if i < (components.length - 1)
            cdata(this_component)
          end
        else
          rawtext CDATA_START
          rawtext s
          rawtext CDATA_END
        end
      else
        rawtext CDATA_START
        yield
        rawtext CDATA_END
      end
    end

    attr_reader :_fortitude_default_assigns

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

      def _fortitude_format_output_changed!(new_value)
        rebuild_text_methods!
        rebuild_tag_methods!
      end

      def _fortitude_extra_assigns_changed!(new_value)
        rebuild_needs!
      end

      def _fortitude_implicit_shared_variable_access_changed!(new_value)
        if new_value
          around_content :transfer_shared_variables
        else
          remove_around_content :transfer_shared_variables, :fail_if_not_present => false
        end
      end

      def _fortitude_enforce_element_nesting_rules_changed!(new_value)
        rebuild_tag_methods!
      end

      def _fortitude_enforce_attribute_rules_changed!(new_value)
        rebuild_tag_methods!
      end

      def _fortitude_use_instance_variables_for_assigns_changed!(new_value)
        rebuild_needs!
      end

      def _fortitude_start_and_end_comments_changed!(new_value)
        if new_value
          around_content :start_and_end_comments
        else
          remove_around_content :start_and_end_comments, :fail_if_not_present => false
        end
      end

      def instance_variable_name_for(assign_name)
        effective_name = assign_name.to_s
        effective_name.gsub!("!", "_fortitude_bang")
        effective_name.gsub!("?", "_fortitude_question")
        "@" + (use_instance_variables_for_assigns ? "" : STANDARD_INSTANCE_VARIABLE_PREFIX) + effective_name
      end

      # def assign_instance_variable_prefix
      #   use_instance_variables_for_assigns ? "" : STANDARD_INSTANCE_VARIABLE_PREFIX
      # end

      def around_content(*method_names)
        return if method_names.length == 0
        @_fortitude_around_content_methods ||= [ ]
        @_fortitude_around_content_methods += method_names.map { |x| x.to_s.strip.downcase.to_sym }
        rebuild_run_content!
      end

      def remove_around_content(*method_names)
        options = method_names.extract_options!
        options.assert_valid_keys(:fail_if_not_present)

        not_found = [ ]
        method_names.each do |method_name|
          not_found << method_name unless (@_fortitude_around_content_methods || [ ]).delete(method_name)
        end

        rebuild_run_content!
        unless (not_found.length == 0) || (options.has_key?(:fail_if_not_present) && (! options[:fail_if_not_present]))
          raise ArgumentError, "no such methods: #{not_found.inspect}"
        end
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
        class_eval(Fortitude::SimpleTemplate.template('text_method_template').result(:format_output => format_output))
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

    rebuild_run_content!
    rebuild_needs!
    rebuild_text_methods!

    helper :capture
    helper :form_tag, :transform => :output_return_value

    def render(*args, &block)
      call_through = lambda { rawtext(invoke_helper(:render, *args, &block)) }

      if self.class.enforce_element_nesting_rules && args[0].kind_of?(Hash) && args[0].has_key?(:partial)
        @_fortitude_rendering_context.record_tag(self, Fortitude::PartialTagPlaceholder.instance, &call_through)
      else
        call_through.call
      end
    end

    tag :html, :newline_before => true
    tag :body, :newline_before => true
    tag :head, :newline_before => true
    tag :link, :newline_before => true, :content_allowed => false
    tag :style, :newline_before => true

    tag :header, :newline_before => true
    tag :nav, :newline_before => true
    tag :section, :newline_before => true
    tag :footer, :newline_before => true

    tag :script, :newline_before => true
    tag :meta, :newline_before => true, :content_allowed => false
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

    tag :br, :content_allowed => false
    tag :hr, :newline_before => true, :content_allowed => false

    def to_html(rendering_context)
      @_fortitude_rendering_context = rendering_context
      @_fortitude_output_buffer_holder = rendering_context.output_buffer_holder

      block = lambda { |*args| @_fortitude_rendering_context.yield_to_view(*args) }

      rendering_context.record_widget(self) do
        begin
          run_content(&block)
        ensure
          @_fortitude_rendering_context = nil
        end
      end
    end

    def rendering_context
      @_fortitude_rendering_context
    end

    def widget(w)
      w.to_html(@_fortitude_rendering_context)
    end

    def doctype!
      dt = self.class.doctype
      raise "You must set a doctype at the class level, using something like 'doctype :html5', before you can use this method." unless dt
      dt.declare!(self)
    end

    def doctype(string)
      rawtext "<!DOCTYPE #{string}>"
    end

    def invoke_helper(name, *args, &block)
      @_fortitude_rendering_context.helpers_object.send(name, *args, &block)
    end

    def javascript(content = nil, &block)
      args = if content.kind_of?(Hash)
        [ self.class.doctype.default_javascript_tag_attributes.merge(content) ]
      elsif content
        if block
          raise ArgumentError, "You can't supply JavaScript content both via text and a block"
        else
          block = lambda { rawtext content }
          [ self.class.doctype.default_javascript_tag_attributes ]
        end
      else
        [ self.class.doctype.default_javascript_tag_attributes ]
      end

      actual_block = block
      if self.class.doctype.needs_cdata_in_javascript_tag?
        actual_block = lambda do
          rawtext "\n//#{CDATA_START}\n"
          block.call
          rawtext "\n//#{CDATA_END}\n"
        end
      end

      @_fortitude_rendering_context.with_indenting_disabled do
        script(*args, &actual_block)
      end
    end

    def t(key, *args)
      base = self.class.translation_base
      if base && key.to_s =~ /^\./
        super("#{base}#{key}", *args)
      else
        super(key, *args)
      end
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
