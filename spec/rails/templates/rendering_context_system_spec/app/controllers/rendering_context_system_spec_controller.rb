require 'simple_rc'

class RenderingContextSystemSpecController < ApplicationController
  def uses_specified_context_in_view
    @the_rendering_context_class = SimpleRc
    @the_rendering_context_options = { :the_value => 12345 }
  end

  def uses_specified_context_in_partials
    @the_rendering_context_class = SimpleRc
    @the_rendering_context_options = { :the_value => 23456 }
  end

  def uses_specified_context_through_nesting
    @the_rendering_context_class = SimpleRc
    @the_rendering_context_options = { :the_value => 34567 }
  end

  def uses_specified_context_in_render_widget
    @the_rendering_context_class = SimpleRc
    @the_rendering_context_options = { :the_value => 45678 }

    render :widget => Views::RenderingContextSystemSpec::RenderWidget.new
  end

  def uses_specified_context_in_render_inline
    @the_rendering_context_class = SimpleRc
    @the_rendering_context_options = { :the_value => 56789 }

    render :type => :fortitude, :inline => (lambda do
      p "context is: #{rendering_context.class.name}, value #{rendering_context.the_value}"
    end)
  end

  def uses_direct_context_in_view
    $invoke_count = 0
    class << self
      def fortitude_rendering_context(options)
        out = SimpleRc.new(options.merge(:the_value => 67890 + $invoke_count))
        $invoke_count += 1
        out
      end
    end
  end

  def uses_direct_context_for_all_widgets
    $invoke_count = 0
    class << self
      def fortitude_rendering_context(options)
        out = SimpleRc.new(options.merge(:the_value => 67890 + $invoke_count))
        $invoke_count += 1
        out
      end
    end
  end

  def create_fortitude_rendering_context(options)
    if @the_rendering_context_class
      @the_rendering_context_class.new((@the_rendering_context_options || { }).merge(options))
    else
      super(options)
    end
  end

  def start_end_widget_basic
    @the_rendering_context_class = SimpleRc
  end

  def start_end_widget_through_partials
    @the_rendering_context_class = SimpleRc
  end
end
