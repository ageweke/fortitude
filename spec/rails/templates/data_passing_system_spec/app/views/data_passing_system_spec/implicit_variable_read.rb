class Views::DataPassingSystemSpec::ImplicitVariableRead < Fortitude::Widget::Html5
  def content
    widget Views::DataPassingSystemSpec::ImplicitVariableReadInner.new
  end
end
