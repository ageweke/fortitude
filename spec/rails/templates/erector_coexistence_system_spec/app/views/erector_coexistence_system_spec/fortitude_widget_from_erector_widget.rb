class Views::ErectorCoexistenceSystemSpec::FortitudeWidgetFromErectorWidget < ::Fortitude::Widgets::Html5
  needs :foo => 'default_foo'

  def content
    text "inside fortitude widget: #{my_helper}, #{foo}"
  end
end
