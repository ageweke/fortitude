class Views::ClassLoadingSystemSpec::AppModels < Fortitude::Widget
  def content
    data = Views::AppModelsHelper.new.data
    p "hello: #{data}"
  end
end
