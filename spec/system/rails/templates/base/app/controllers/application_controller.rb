class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Exception do |exception|
    render :json => {
      :exception => {
        :class => exception.class.name,
        :message => exception.message,
        :backtrace => exception.backtrace
      }
    }
  end

  def rails_is_working
    render :text => "Rails version: #{Rails.version}"
  end
end
