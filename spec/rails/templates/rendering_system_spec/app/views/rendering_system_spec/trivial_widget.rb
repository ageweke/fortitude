class Views::RenderingSystemSpec::TrivialWidget < Fortitude::Widget::Html5
  def content
    p "hello, world"
  end
end
