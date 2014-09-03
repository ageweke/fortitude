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
end
