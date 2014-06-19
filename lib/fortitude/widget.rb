require 'fortitude/widget/widget_class_inheritable_attributes'
require 'fortitude/widget/tags'
require 'fortitude/widget/needs'
require 'fortitude/widget/modules_and_subclasses'
require 'fortitude/widget/doctypes'
require 'fortitude/widget/start_and_end_comments'
require 'fortitude/widget/tag_like_methods'
require 'fortitude/widget/staticization'

require 'fortitude/tag'
require 'fortitude/tags_module'
require 'fortitude/errors'
require 'fortitude/assigns_proxy'
require 'fortitude/doctypes'
require 'fortitude/partial_tag_placeholder'
require 'fortitude/staticized_method'
require 'fortitude/rendering_context'
require 'fortitude/tag_store'
require 'fortitude/rails/yielded_object_outputter'
require 'active_support/core_ext/hash'
require 'active_support/notifications'

module Fortitude
  # TODO: rename all non-interface methods as _fortitude_*
  # TODO: Make 'element' vs. 'tag' naming consistent
  # TODO: Make naming consistent across enforcement/validation/rules (tag nesting, attributes, ID uniqueness)
  class Widget
    include Fortitude::Widget::WidgetClassInheritableAttributes
    include Fortitude::Widget::Tags
    include Fortitude::Widget::Needs
    include Fortitude::Widget::ModulesAndSubclasses
    include Fortitude::Widget::Doctypes
    include Fortitude::Widget::StartAndEndComments
    include Fortitude::Widget::TagLikeMethods
    include Fortitude::Widget::Staticization

    if defined?(::Rails)
      require 'fortitude/rails/widget_methods'
      include Fortitude::Rails::WidgetMethods
    else
      require 'fortitude/widget/non_rails_widget_methods'
      include Fortitude::Widget::NonRailsWidgetMethods
    end

    # INTEGRATION ===================================================================================================
    class << self
      # INTERNAL USE ONLY
      def rebuilding(what, why, klass, &block)
        ActiveSupport::Notifications.instrument("fortitude.rebuilding", :what => what, :why => why, :originating_class => klass, :class => self, &block)
      end
      private :rebuilding

      # INTERNAL USE ONLY
      def rebuild_text_methods!(why, klass = self)
        rebuilding(:text_methods, why, klass) do
          class_eval(Fortitude::SimpleTemplate.template('text_method_template').result(:format_output => format_output, :needs_element_rules => self.enforce_element_nesting_rules))
          direct_subclasses.each { |s| s.rebuild_text_methods!(why, klass) }
        end
      end
    end

    # RUBY CALLBACK
    def method_missing(name, *args, &block)
      if self.class.extra_assigns == :use
        ivar_name = self.class.instance_variable_name_for_need(name)
        return instance_variable_get(ivar_name) if instance_variable_defined?(ivar_name)
      end

      if self.class.automatic_helper_access && @_fortitude_rendering_context && @_fortitude_rendering_context.helpers_object && @_fortitude_rendering_context.helpers_object.respond_to?(name, true)
        @_fortitude_rendering_context.helpers_object.send(name, *args, &block)
      else
        super(name, *args, &block)
      end
    end

    _fortitude_on_class_inheritable_attribute_change(
      :format_output, :enforce_element_nesting_rules) do |attribute_name, old_value, new_value|
      rebuild_text_methods!(:"#{attribute_name}_changed")
    end

    _fortitude_on_class_inheritable_attribute_change(
      :format_output, :close_void_tags, :enforce_element_nesting_rules,
      :enforce_attribute_rules, :enforce_id_uniqueness) do |attribute_name, old_value, new_value|
      rebuild_tag_methods!(:"#{attribute_name}_changed")
    end

    _fortitude_on_class_inheritable_attribute_change(
      :debug, :extra_assigns, :use_instance_variables_for_assigns) do |attribute_name, old_value, new_value|
      rebuild_needs!(:"#{attribute_name}_changed")
    end

    _fortitude_on_class_inheritable_attribute_change(:implicit_shared_variable_access) do |attribute_name, old_value, new_value|
      if new_value
        around_content :transfer_shared_variables
      else
        remove_around_content :transfer_shared_variables, :fail_if_not_present => false
      end
    end

    _fortitude_on_class_inheritable_attribute_change(:start_and_end_comments) do |attribute_name, old_value, new_value|
      if new_value
        around_content :start_and_end_comments
      else
        remove_around_content :start_and_end_comments, :fail_if_not_present => false
      end
    end

    # CONTENT ======================================================================================================
    # PUBLIC API
    def content
      raise "Must override in #{self.class.name}"
    end

    class << self
      # INTERNAL USE ONLY
      def rebuild_run_content!(why, klass = self)
        rebuilding(:run_content, why, klass) do
          acm = around_content_methods
          text = "def run_content(*args, &block)\n"
          text += "  out = nil\n"
          acm.each_with_index do |method_name, index|
            text += "  " + ("  " * index) + "#{method_name}(*args) do\n"
          end

          if has_localized_content_methods?
            text += "  " + ("  " * acm.length) + "the_locale = widget_locale\n"
            text += "  " + ("  " * acm.length) + "locale_method_name = \"localized_content_\#{the_locale}\" if the_locale\n"
            text += "  " + ("  " * acm.length) + "out = if locale_method_name && respond_to?(locale_method_name)\n"
            text += "  " + ("  " * acm.length) + "  send(locale_method_name, *args, &block)\n"
            text += "  " + ("  " * acm.length) + "else\n"
            text += "  " + ("  " * acm.length) + "  content(*args, &block)\n"
            text += "  " + ("  " * acm.length) + "end\n"
          else
            text += "  " + ("  " * acm.length) + "out = content(*args, &block)\n"
          end

          (0..(acm.length - 1)).each do |index|
            text += "  " + ("  " * (acm.length - (index + 1))) + "end\n"
          end
          text += "  out\n"
          text += "end"

          class_eval(text)

          direct_subclasses.each { |s| s.rebuild_run_content!(why, klass) }
        end
      end
    end

    # AROUND_CONTENT ================================================================================================
    class << self
      # PUBLIC API
      def around_content(*method_names)
        return if method_names.length == 0
        @_fortitude_around_content_methods ||= [ ]
        @_fortitude_around_content_methods += method_names.map { |x| x.to_s.strip.downcase.to_sym }
        rebuild_run_content!(:around_content_added)
      end

      # PUBLIC API
      def remove_around_content(*method_names)
        options = method_names.extract_options!
        options.assert_valid_keys(:fail_if_not_present)

        not_found = [ ]
        method_names.each do |method_name|
          not_found << method_name unless (@_fortitude_around_content_methods || [ ]).delete(method_name)
        end

        rebuild_run_content!(:around_content_removed)
        unless (not_found.length == 0) || (options.has_key?(:fail_if_not_present) && (! options[:fail_if_not_present]))
          raise ArgumentError, "no such methods: #{not_found.inspect}"
        end
      end

      # INTERNAL USE ONLY
      def around_content_methods
        superclass_methods = if superclass.respond_to?(:around_content_methods)
          superclass.around_content_methods
        else
          [ ]
        end

        (superclass_methods + this_class_around_content_methods).uniq
      end

      # INTERNAL USE ONLY
      def this_class_around_content_methods
        @_fortitude_around_content_methods ||= [ ]
      end
      private :this_class_around_content_methods
    end

    # LOCALIZATION ==================================================================================================
    class << self
      # RUBY CALLBACK
      def method_added(method_name)
        super(method_name)
        check_localized_methods!
      end

      # RUBY CALLBACK
      def method_removed(method_name)
        super(method_name)
        check_localized_methods!
      end

      # RUBY CALL
      def include(*args)
        super(*args)
        check_localized_methods!
      end

      LOCALIZED_CONTENT_PREFIX = "localized_content_"

      # INTERNAL USE ONLY
      def check_localized_methods!(original_class = self)
        currently_has = instance_methods(true).detect { |i| i =~ /^#{LOCALIZED_CONTENT_PREFIX}/i }
        if currently_has != @last_localized_methods_check_has
          @last_localized_methods_check_has = currently_has
          rebuild_run_content!(:localized_methods_presence_changed, original_class)
        end
        direct_subclasses.each { |s| s.check_localized_methods!(original_class) }
      end

      # INTERNAL USE ONLY
      def has_localized_content_methods?
        !! (instance_methods(true).detect { |i| i =~ /^#{LOCALIZED_CONTENT_PREFIX}/i })
      end
      private :has_localized_content_methods?
    end

    # PUBLIC API
    def t(key, *args)
      base = self.class.translation_base
      if base && key.to_s =~ /^\./
        super("#{base}#{key}", *args)
      else
        super(key, *args)
      end
    end

    # PUBLIC API
    def ttext(key, *args)
      tag_text t(".#{key}", *args)
    end

    # HELPERS =======================================================================================================
    class << self
      # PUBLIC API
      def helper(*args)
        options = args.extract_options!
        options.assert_valid_keys(:transform, :call, :output_yielded_methods)

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

          block_transform = "effective_block = block"

          yielded_methods = options[:output_yielded_methods]
          if yielded_methods
            block_transform = <<-EOS
      effective_block = lambda do |yielded_object|
        block.call(Fortitude::Rails::YieldedObjectOutputter.new(self, yielded_object, #{yielded_methods.inspect}))
      end
EOS
          end

          text = <<-EOS
    def #{name}(*args, &block)
      #{block_transform}
      #{prefix}(@_fortitude_rendering_context.helpers_object.#{source_method_name}(*args, &effective_block))#{suffix}
    end
EOS

          helpers_module.module_eval(text)
        end
      end
    end

    # PUBLIC API
    def invoke_helper(name, *args, &block)
      @_fortitude_rendering_context.helpers_object.send(name, *args, &block)
    end

    # CAPTURING =====================================================================================================
    # PUBLIC API
    def capture(&block)
      helpers = @_fortitude_rendering_context.helpers_object
      if helpers && helpers.respond_to?(:capture, true) &&
        [ 0, -1].include?(helpers.method(:capture).arity)
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

    # RENDERING =============================================================================================
    # PUBLIC API
    def render(*args, &block)
      call_through = lambda do
        @_fortitude_rendering_context.record_widget(args) do
          tag_rawtext(invoke_helper(:render, *args, &block))
        end
      end

      if self.class.enforce_element_nesting_rules && args[0].kind_of?(Hash) && args[0].has_key?(:partial)
        @_fortitude_rendering_context.record_tag(self, Fortitude::PartialTagPlaceholder.instance, &call_through)
      else
        call_through.call
      end
    end

    # PUBLIC API
    def to_html(rendering_context)
      @_fortitude_rendering_context = rendering_context
      @_fortitude_output_buffer_holder = rendering_context.output_buffer_holder

      block = lambda { |*args| @_fortitude_rendering_context.yield_from_widget(*args) }

      rendering_context.record_widget(self) do
        begin
          run_content(&block)
        ensure
          @_fortitude_rendering_context = nil
        end
      end
    end

    # PUBLIC API
    def rendering_context
      @_fortitude_rendering_context
    end

    # PUBLIC API
    def widget(w)
      w.to_html(@_fortitude_rendering_context)
    end

    # PUBLIC API
    def output_buffer
      @_fortitude_output_buffer_holder.output_buffer
    end

    # PUBLIC API
    def initialize(assigns = { })
      assign_locals_from(assigns)
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

    # PUBLIC API
    def yield_from_widget(*args)
      @_fortitude_rendering_context.yield_from_widget(*args)
    end

    # TEMPORARY OVERRIDES ===========================================================================================
    # PUBLIC API
    def with_element_nesting_rules(on_or_off)
      raise ArgumentError, "We aren't even enforcing nesting rules in the first place" if on_or_off && (! self.class.enforce_element_nesting_rules)
      @_fortitude_rendering_context.with_element_nesting_validation(on_or_off) { yield }
    end

    # PUBLIC API
    def with_attribute_rules(on_or_off)
      raise ArgumentError, "We aren't even enforcing attribute rules in the first place" if on_or_off && (! self.class.enforce_attribute_rules)
      @_fortitude_rendering_context.with_attribute_validation(on_or_off) { yield }
    end

    # PUBLIC API
    def with_id_uniqueness(on_or_off)
      raise ArgumentError, "We aren't even enforcing ID uniqueness in the first place" if on_or_off && (! self.class.enforce_id_uniqueness)
      @_fortitude_rendering_context.with_id_uniqueness(on_or_off) { yield }
    end

    # CODA ==========================================================================================================
    rebuild_run_content!(:initial_setup)
    rebuild_needs!(:initial_setup)
    rebuild_text_methods!(:initial_setup)
  end
end
