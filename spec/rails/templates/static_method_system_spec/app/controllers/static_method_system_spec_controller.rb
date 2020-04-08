class StaticMethodSystemSpecController < ApplicationController
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] if params[:locale]
  end

  def allows_helper_access
    # nothing here
  end

  def localization
    # nothing here
  end
end
