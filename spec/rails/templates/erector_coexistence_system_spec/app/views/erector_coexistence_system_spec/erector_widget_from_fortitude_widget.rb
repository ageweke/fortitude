class Views::ErectorCoexistenceSystemSpec::ErectorWidgetFromFortitudeWidget < ::Erector::Widget
  needs :foo => 'default_foo'

  def content
    text "inside erector widget: #{my_helper}, #{@foo}"
  end
end
