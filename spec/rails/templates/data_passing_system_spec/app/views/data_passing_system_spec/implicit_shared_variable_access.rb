class Views::DataPassingSystemSpec::ImplicitSharedVariableAccess < Fortitude::Widget
  def content
    widget Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInner.new(:foo => "foo_from_outer")
  end
end
