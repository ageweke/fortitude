class Views::RenderingSystemSpec::TrivialWidget < Fortitude::Widgets::Html5
  def content
    p "hello, world"
  end
end
