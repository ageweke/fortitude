class Views::LayoutsSystemSpec::WidgetInsideErbLayout < Fortitude::Widget
  def content
    @foo = "foo_from_widget_inside_erb_layout"
    set_instance_variable("foo", "foo_from_widget_inside_erb_layout")
    p "this is widget_inside_erb_layout"
    $order << :widget_inside_erb_layout
    p "order inside widget: #{$order.inspect}"
  end
end
