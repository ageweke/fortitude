class LocalizationSystemSpecController < ApplicationController
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] if params[:locale]
  end

  def i18n_t
    # nothing here
  end

  def t
    # nothing here
  end

  def content_method
    # nothing here
  end

  def native_support
    # nothing here
  end

  def readjust_base
    # nothing here
  end

  def explicit_html
    # nothing here
  end
end
