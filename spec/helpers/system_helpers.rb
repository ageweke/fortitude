require 'active_support'
require 'fortitude'

module SystemHelpers
  extend ActiveSupport::Concern

  class IvarAccessible
    def [](x)
      instance_variable_get("@#{x}")
    end

    def []=(x, y)
      instance_variable_set("@#{x}", y)
    end
  end

  attr_reader :ivars

  def rc(options = { })
    options[:instance_variables_object] = ivars unless options.has_key?(:instance_variables_object)
    ::Fortitude::RenderingContext.new(options)
  end

  def html_from(rendering_context)
    rendering_context.output_buffer_holder.output_buffer.to_s
  end

  def define_helper(name, &block)
    @helpers_class.send(:define_method, name, &block)
  end

  def widget_class(options = { }, &block)
    klass = Class.new(options[:superclass] || ::Fortitude::Widget, &block)
    $spec_widget_seq ||= 0
    $spec_widget_seq += 1
    ::Object.const_set("SpecWidget#{$spec_widget_seq}", klass)
    klass
  end

  def widget_class_with_content(options = { }, &block)
    wc = widget_class(options)
    wc.send(:define_method, :content, &block)
    wc
  end

  def render(widget_or_class, options = { })
    widget = if widget_or_class.kind_of?(Class)
      widget_or_class.new(options[:assigns] || { })
    else
      widget_or_class
    end
    rendering_context = options[:rendering_context] || rc
    widget.to_html(rendering_context)
    html_from(rendering_context)
  end

  def render_content(options = { }, &block)
    widget_class = widget_class_with_content(options, &block)
    render(widget_class, options)
  end

  included do
    before :each do
      @helpers_class = Class.new
      @helpers = @helpers_class.new
      @ivars = IvarAccessible.new
      @yield_block = double("yield_block")
    end
  end
end
