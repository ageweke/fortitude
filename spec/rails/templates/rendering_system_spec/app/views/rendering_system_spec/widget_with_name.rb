class Views::RenderingSystemSpec::WidgetWithName < Fortitude::Widget::Html5
  needs :name

  def content
    p "widget_with_name: #{name}"
  end
end
