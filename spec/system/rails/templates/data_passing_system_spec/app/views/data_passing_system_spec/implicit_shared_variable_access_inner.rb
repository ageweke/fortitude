class Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInner < Fortitude::Widget
  implicit_shared_variable_access true
  needs :foo

  def content
    p "foo: #{@foo.inspect}"
  end
end
