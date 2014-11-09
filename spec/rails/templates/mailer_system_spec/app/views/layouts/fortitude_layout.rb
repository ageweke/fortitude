class Views::Layouts::FortitudeLayout < Fortitude::Widgets::Html5
  def content
    div {
      p "this is the Fortitude layout"
      yield
    }
  end
end
