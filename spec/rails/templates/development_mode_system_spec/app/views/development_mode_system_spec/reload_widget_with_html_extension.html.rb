class Views::DevelopmentModeSystemSpec::ReloadWidgetWithHtmlExtension < Fortitude::Widgets::Html5
  include Views::Shared::SomeModule
  needs :datum

  def content
    p "with_html_extension: datum #{datum} datum, helper: #{some_helper}"
  end
end
