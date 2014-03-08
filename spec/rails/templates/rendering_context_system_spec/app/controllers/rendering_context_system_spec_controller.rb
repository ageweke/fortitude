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

  def create_fortitude_rendering_context(options)
    @the_rendering_context_class.new((@the_rendering_context_options || { }).merge(options))
  end

  def start_end_widget_basic
    @the_rendering_context_class = SimpleRc
  end
end
