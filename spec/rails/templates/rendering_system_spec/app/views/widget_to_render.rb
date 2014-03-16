class Views::WidgetToRender < Fortitude::Widget::Html5
  needs :name

  def content
    p "hello from a widget named #{name}"
  end
end
