class Views::DataPassingSystemSpec::ImplicitSharedVariableAccess < Fortitude::Widgets::Html5
  def content
    widget Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInner.new(:foo => "foo_from_outer")
  end
end
