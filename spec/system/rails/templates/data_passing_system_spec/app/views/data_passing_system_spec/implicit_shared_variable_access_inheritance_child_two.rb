class Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInheritanceChildTwo < Views::DataPassingSystemSpec::ImplicitSharedVariableAccessInheritanceParent
  def content
    text "C2: foo is #{@foo}, bar is #{@bar}"
  end
end
