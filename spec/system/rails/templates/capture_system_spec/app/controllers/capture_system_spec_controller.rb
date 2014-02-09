class CaptureSystemSpecController < ApplicationController
  def capture_widget_from_erb
    # nothing here
  end

  def capture_erb_from_widget
    # nothing here
  end

  def capture_widget_from_widget
    # nothing here
  end

  def widget_content_for
    render :layout => 'erb_layout_needing_content'
  end
end
