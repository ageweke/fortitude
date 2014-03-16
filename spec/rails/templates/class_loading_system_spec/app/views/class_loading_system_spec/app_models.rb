class Views::ClassLoadingSystemSpec::AppModels < Fortitude::Widget::Html5
  def content
    data = Views::AppModelsHelper.new.data
    p "hello: #{data}"
  end
end
