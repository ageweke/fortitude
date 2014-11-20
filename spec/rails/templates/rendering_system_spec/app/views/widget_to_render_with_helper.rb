class Views::WidgetToRenderWithHelper < Fortitude::Widgets::Html5
  def content
    p "hello from a widget named #{my_name_helper}"
  end
end
