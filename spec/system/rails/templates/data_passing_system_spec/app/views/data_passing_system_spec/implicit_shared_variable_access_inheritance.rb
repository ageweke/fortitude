class Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInheritance < Fortitude::Widget
  def content
    widget Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInheritanceChildOne.new
    widget Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInheritanceChildTwo.new
  end
end
