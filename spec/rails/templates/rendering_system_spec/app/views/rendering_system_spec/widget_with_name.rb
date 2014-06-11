class Views::RenderingSystemSpec::WidgetWithName < Fortitude::Widgets::Html5
  needs :name

  def content
    p "widget_with_name: #{name}"
  end
end
