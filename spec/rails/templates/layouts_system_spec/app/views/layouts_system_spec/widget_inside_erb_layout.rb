class Views::LayoutsSystemSpec::WidgetInsideErbLayout < Fortitude::Widgets::Html5
  def content
    shared_variables[:foo] = "foo_from_widget_inside_erb_layout"
    p "this is widget_inside_erb_layout"
    $order << :widget_inside_erb_layout
    p "order inside widget: #{$order.inspect}"
  end
end
