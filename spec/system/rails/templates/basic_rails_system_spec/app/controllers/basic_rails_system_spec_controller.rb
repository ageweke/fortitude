class BasicRailsSystemSpecController < ApplicationController
  def trivial_widget
  end

  def the_class_should_not_load
    render :text => BasicRailsSystemSpec::ClassShouldNotLoad.new.to_s
  end

  def erb_to_widget_with_render_partial
  end

  def prefers_erb_partial
  end

  def fortitude_partial_with_underscore
  end
end
