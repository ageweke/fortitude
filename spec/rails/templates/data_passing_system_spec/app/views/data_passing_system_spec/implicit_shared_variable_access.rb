class Views::DataPassingSystemSpec::ImplicitSharedVariableAccess < Fortitude::Widget::Html5
  def content
    widget Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInner.new(:foo => "foo_from_outer")
  end
end
