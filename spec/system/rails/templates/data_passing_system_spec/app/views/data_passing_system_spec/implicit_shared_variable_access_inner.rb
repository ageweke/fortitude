class Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInner < Fortitude::Widget
  implicit_shared_variable_access
  needs :foo

  def content
    p "foo: #{@foo.inspect}"
  end
end
