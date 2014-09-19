class Views::BasicRailsSystemSpec::DoubleRenderTwo < Fortitude::Widgets::Html5
  needs :rendered_string

  def content
    rawtext rendered_string
    p "goodbye, world"
  end
end
