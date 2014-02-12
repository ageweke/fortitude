class Views::Layouts::Application < Fortitude::Widget
  def content
    html do
      head do
        title "widget_default_layout"
      end
      body do
        yield
      end
    end
  end
end
