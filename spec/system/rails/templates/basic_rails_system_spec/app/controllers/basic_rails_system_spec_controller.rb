class BasicRailsSystemSpecController < ApplicationController
  def trivial_widget
  end

  def the_class_should_not_load
    render :text => BasicRailsSystemSpec::ClassShouldNotLoad.new.to_s
  end


  def render_with_colon_action
    render :action => 'trivial_widget'
  end

  def render_with_colon_template
    render :template => 'basic_rails_system_spec/trivial_widget'
  end

  def erb_to_widget_with_render_partial
  end

  def prefers_erb_partial
  end

  def fortitude_partial_with_underscore
  end
end
