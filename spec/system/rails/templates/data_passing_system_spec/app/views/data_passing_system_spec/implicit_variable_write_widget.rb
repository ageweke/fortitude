class Views::DataPassingSystemSpec::ImplicitVariableWriteWidget < Fortitude::Widget
  implicit_shared_variable_access

  def content
    @foo = "foo_from_widget"
  end
end
