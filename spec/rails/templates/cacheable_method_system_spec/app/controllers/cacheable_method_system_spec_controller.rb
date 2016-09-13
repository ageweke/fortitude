class CacheableMethodSystemSpecController < ApplicationController
  before_filter :set_locale

  def set_locale
    I18n.locale = params[:locale] if params[:locale]
  end

  def localization
    # nothing here
  end

  def outside_of_views_path
    require 'arbitrary_name/cached_widget'
    render :widget => ArbitraryName::CachedWidget.new
  end

  def outside_of_views_path_two
    require 'arbitrary_name/cached_widget_two'
    render :widget => ArbitraryName::CachedWidgetTwo.new
  end
end
