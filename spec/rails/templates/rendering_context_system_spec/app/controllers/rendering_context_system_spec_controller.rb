require 'simple_rc'

class RenderingContextSystemSpecController < ApplicationController
  def uses_specified_context_in_view
    @the_rendering_context_class = SimpleRc
    @the_rendering_context_options = { :the_value => 12345 }
  end

  def fortitude_rendering_context(options)
    @the_rendering_context_class.new((@the_rendering_context_options || { }).merge(options))
  end
end
