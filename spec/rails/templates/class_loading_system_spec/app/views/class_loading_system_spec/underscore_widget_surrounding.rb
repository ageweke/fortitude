class Views::ClassLoadingSystemSpec::UnderscoreWidgetSurrounding < Fortitude::Widgets::Html5
  def content
    text "surrounding_widget before"
    widget Views::ClassLoadingSystemSpec::UnderscoreWidget
    text "surrounding_widget after"
  end
end
