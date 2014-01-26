class BasicRailsSystemSpecController < ApplicationController
  def rails_is_working
    render :text => "Rails version: #{Rails.version}"
  end

  def trivial_widget
  end
end
