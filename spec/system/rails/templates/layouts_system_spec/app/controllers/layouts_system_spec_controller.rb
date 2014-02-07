class LayoutsSystemSpecController < ApplicationController
  def widget_inside_erb_layout
    $order = [ ]
  end

  def erb_inside_widget_layout
    $order = [ ]
    render :layout => 'widget_layout'
  end
end
