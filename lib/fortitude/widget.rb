require 'fortitude/widget/widget_class_inheritable_attributes'
require 'fortitude/widget/tags'
require 'fortitude/widget/needs'
require 'fortitude/widget/modules_and_subclasses'
require 'fortitude/widget/doctypes'
require 'fortitude/widget/start_and_end_comments'
require 'fortitude/widget/tag_like_methods'
require 'fortitude/widget/staticization'
require 'fortitude/widget/integration'
require 'fortitude/widget/content'
require 'fortitude/widget/around_content'
require 'fortitude/widget/localization'

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
    include Fortitude::Widget::Integration
    include Fortitude::Widget::Content
    include Fortitude::Widget::AroundContent
    include Fortitude::Widget::Localization

    if defined?(::Rails)
      require 'fortitude/rails/widget_methods'
      include Fortitude::Rails::WidgetMethods
    else
      require 'fortitude/widget/non_rails_widget_methods'
      include Fortitude::Widget::NonRailsWidgetMethods
    end

    # LOCALIZATION ==================================================================================================

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
