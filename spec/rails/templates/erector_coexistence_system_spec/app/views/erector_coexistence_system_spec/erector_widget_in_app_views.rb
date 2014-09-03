class Views::ErectorCoexistenceSystemSpec::ErectorWidgetInAppViews < Erector::Widget
  needs :foo

  def content
    p.some_class "this is Erector: foo = #{@foo}"
  end
end
