class BasicRailsSystemSpecController < ApplicationController
  def rails_is_working
    render :text => "Rails version: #{Rails.version}"
  end
end
