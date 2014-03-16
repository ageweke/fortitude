class Views::RenderingSystemSpec::WidgetLayoutForPartial < Fortitude::Widget::Html5
  def content
    text "widget_partial_layout before"
    yield
    text "widget_partial_layout after"
  end
end
