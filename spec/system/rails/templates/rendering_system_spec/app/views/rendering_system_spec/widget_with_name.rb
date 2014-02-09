class Views::RenderingSystemSpec::WidgetWithName < Fortitude::Widget
  needs :name

  def content
    p "widget_with_name: #{name}"
  end
end
