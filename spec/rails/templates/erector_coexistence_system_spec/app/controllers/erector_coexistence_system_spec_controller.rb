class ErectorCoexistenceSystemSpecController < ApplicationController
  prepend_view_path "app/v/views"

  def fortitude_widget_in_app_views
    @foo = "bar"
  end

  def fortitude_widget_in_app_v_views
    @foo = "marph"
  end

  def erector_widget_in_app_views
    @foo = "baz"
  end

  def erector_widget_in_app_v_views
    @foo = "quux"
  end

  def render_widget_fortitude
    render :widget => ::Views::FortitudeWidget.new
  end

  def render_widget_erector
    render :widget => ::Views::ErectorWidget.new
  end

  def render_widget_fortitude_class
    render :widget => ::Views::FortitudeWidget
  end

  def render_widget_erector_class
    render :widget => ::Views::ErectorWidget
  end

  def render_erector_widget_from_fortitude_widget
    @instantiate_widget = !! (params[:instantiate_widget] == "true")
  end

  def render_fortitude_widget_from_erector_widget
    # nothing here
  end
end
