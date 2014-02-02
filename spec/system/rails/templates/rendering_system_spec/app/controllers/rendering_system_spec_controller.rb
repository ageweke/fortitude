class RenderingSystemSpecController < ApplicationController
  def render_with_colon_action
    render :action => 'trivial_widget'
  end

  def render_with_colon_template
    render :template => 'rendering_system_spec/trivial_widget'
  end

  def render_widget
    render :widget => Views::WidgetToRender.new(:name => 'Fred')
  end
end
