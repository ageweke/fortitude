class Views::ErectorCoexistenceSystemSpec::FortitudeWidget < ::Fortitude::Widgets::Html5
  needs :name

  def content
    p "this is a Fortitude widget, #{name}"
  end
end
