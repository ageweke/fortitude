class Views::DataPassingSystemSpec::ExplicitControllerVariableRead < Fortitude::Widget::Html5
  def content
    p "explicit foo as symbol: #{shared_variables[:foo]}"
    p "explicit foo as string: #{shared_variables['foo']}"
  end
end
