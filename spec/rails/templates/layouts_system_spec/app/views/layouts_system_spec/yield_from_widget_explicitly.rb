class Views::LayoutsSystemSpec::YieldFromWidgetExplicitly < Fortitude::Widget::Html5
  def content
    p "this is yield_from_widget_explicitly"
  end
end
