class Views::DataPassingSystemSpec::ImplicitVariableReadInner < Fortitude::Widgets::Html5
  implicit_shared_variable_access true

  def content
    p "inner widget foo: #{@foo}"
  end
end
