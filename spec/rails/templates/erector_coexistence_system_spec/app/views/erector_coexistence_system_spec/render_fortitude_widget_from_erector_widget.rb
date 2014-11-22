class Views::ErectorCoexistenceSystemSpec::RenderFortitudeWidgetFromErectorWidget < ::Erector::Widget
  needs :instantiate_widget

  def content
    text "before fortitude widget: #{my_helper}"
    if @instantiate_widget
      widget Views::ErectorCoexistenceSystemSpec::FortitudeWidgetFromErectorWidget.new(:foo => 'passed_foo')
    else
      widget Views::ErectorCoexistenceSystemSpec::FortitudeWidgetFromErectorWidget, :foo => 'passed_foo'
    end
    text "after fortitude widget: #{my_helper}"
  end
end
