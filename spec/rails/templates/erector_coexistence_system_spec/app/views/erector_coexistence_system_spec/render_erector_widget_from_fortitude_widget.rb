class Views::ErectorCoexistenceSystemSpec::RenderErectorWidgetFromFortitudeWidget < Fortitude::Widgets::Html5
  needs :instantiate_widget

  def content
    text "before erector widget: #{my_helper}"
    if instantiate_widget
      widget Views::ErectorCoexistenceSystemSpec::ErectorWidgetFromFortitudeWidget.new(:foo => 'passed_foo')
    else
      widget Views::ErectorCoexistenceSystemSpec::ErectorWidgetFromFortitudeWidget, :foo => 'passed_foo'
    end
    text "after erector widget: #{my_helper}"
  end
end
