class CacheableMethodSystemSpecController < ApplicationController
  before_filter :set_locale

  def set_locale
    I18n.locale = params[:locale] if params[:locale]
  end

  def localization
    # nothing here
  end
end
