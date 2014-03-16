class Views::ClassLoadingSystemSpec::UseModelsWidgetFromViewWidget < Fortitude::Widget::Html5
  def content
    p "about to run the models widget"
    widget Views::ModelsWidget.new
    p "ran the models widget"
  end
end
