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

  class TestDoctype < Fortitude::Doctypes::Base
    def initialize
      super(:test_doctype, "FORTITUDE TEST")
    end

    def close_void_tags_must_be
      nil
    end

    def default_javascript_tag_attributes
      { }
    end

    def needs_cdata_in_javascript_tag?
      false
    end

    tag :p, :newline_before => true, :valid_attributes => %w{class}, :can_enclose => %w{a span br b _text}, :spec => 'THE_SPEC_FOR_P'
    tag :div, :newline_before => true, :valid_attributes => %w{aaaaaaaaaaaaaa}, :can_enclose => %w{div p hr}
    tag :span
    tag :hr, :content_allowed => false
    tag :br, :content_allowed => false, :spec => 'THE_SPEC_FOR_BR'
    tag :a
    tag :b
    tag :nav, :newline_before => true
    tag :h1, :newline_before => true
    tag :img, :content_allowed => false
    tag :script, :newline_before => true, :escape_direct_content => false
    tag :head, :newline_before => true
    tag :style, :newline_before => true, :escape_direct_content => false
  end

  class TestWidgetClass < Fortitude::Widget
    doctype TestDoctype.new
  end

  def widget_class(options = { }, &block)
    klass = Class.new(options[:superclass] || TestWidgetClass, &block)
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

  def capture_exception(klass = StandardError, &block)
    out = nil
    begin
      block.call
    rescue klass => e
      out = e
    end
    raise "Exception of class #{klass.inspect} was expected, but none was raised" unless out
    out
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
