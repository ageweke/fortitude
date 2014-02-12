class Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInheritanceChildOne < Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInheritanceParent
  implicit_shared_variable_access false

  def content
    text "C1: foo is #{@foo}, bar is #{@bar}"
  end
end
