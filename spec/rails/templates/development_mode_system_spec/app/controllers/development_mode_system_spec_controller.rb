class DevelopmentModeSystemSpecController < ApplicationController
  def reload_widget
    @datum = "one"
  end

  def reload_widget_with_html_extension
    @datum = "five"
  end

  def sample_output
    @name = "Jessica"
  end
end
