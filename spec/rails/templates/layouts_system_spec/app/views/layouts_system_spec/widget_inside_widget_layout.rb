class Views::LayoutsSystemSpec::WidgetInsideWidgetLayout < Fortitude::Widgets::Html5
  def content
    shared_variables[:foo] = "foo_from_widget_inside_widget_layout"
    p "this is widget_inside_widget_layout"
    $order << :widget_inside_widget_layout
    p "order inside widget: #{$order.inspect}"
  end
end
