class Views::ErbIntegrationSystemSpec::ErbToWidgetWithWidgetWidget < Fortitude::Widgets::Html5
  needs :name

  def content
    p "erb to widget with widget widget, name #{name}"
  end
end
