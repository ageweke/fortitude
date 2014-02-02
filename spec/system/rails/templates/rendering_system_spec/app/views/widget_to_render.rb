class Views::WidgetToRender < Fortitude::Widget
  needs :name

  def content
    p "hello from a widget named #{name}"
  end
end
