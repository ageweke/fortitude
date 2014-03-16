class Views::BasicRailsSystemSpec::TrivialWidget < Fortitude::Widget::Html5
  def content
    p "hello, world"
  end
end
