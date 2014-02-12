class LayoutsSystemSpecController < ApplicationController
  def widget_inside_erb_layout
    $order = [ ]
  end

  def erb_inside_widget_layout
    $order = [ ]
    render :layout => 'widget_layout'
  end

  def widget_inside_widget_layout
    $order = [ ]
    render :layout => 'widget_layout'
  end

  def render_widget
    render :widget => Views::LayoutsSystemSpec::TheRenderWidget.new
  end

  def render_widget_without_layout
    render :widget => Views::LayoutsSystemSpec::TheRenderWidget.new, :layout => false
  end

  def render_widget_with_alt_layout
    render :widget => Views::LayoutsSystemSpec::TheRenderWidget.new, :layout => 'alternate'
  end

  def yield_to_view_explicitly
    render :layout => 'explicit_yield'
  end
end
