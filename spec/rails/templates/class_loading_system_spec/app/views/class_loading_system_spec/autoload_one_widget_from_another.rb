class Views::ClassLoadingSystemSpec::AutoloadOneWidgetFromAnother < Fortitude::Widgets::Html5
  def content
    p "about to run the sub widget"
    widget Views::SubWidget.new
    p "ran the sub widget"
  end
end
