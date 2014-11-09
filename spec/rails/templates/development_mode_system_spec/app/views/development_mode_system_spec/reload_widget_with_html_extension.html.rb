class Views::DevelopmentModeSystemSpec::ReloadWidgetWithHtmlExtension < Fortitude::Widgets::Html5
  needs :datum

  def content
    p "with_html_extension_before_reload: datum #{datum} datum"
  end
end
