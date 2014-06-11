class Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInheritance < Fortitude::Widgets::Html5
  def content
    widget Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInheritanceChildOne.new
    widget Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInheritanceChildTwo.new
  end
end
