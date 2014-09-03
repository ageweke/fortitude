class Views::ErectorCoexistenceSystemSpec::FortitudeWidgetInAppViews < Fortitude::Widgets::Html5
  needs :foo

  def content
    p "this is Fortitude: foo = #{foo}"
  end
end
