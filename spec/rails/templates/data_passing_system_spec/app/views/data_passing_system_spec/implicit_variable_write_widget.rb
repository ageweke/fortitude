class Views::DataPassingSystemSpec::ImplicitVariableWriteWidget < Fortitude::Widget::Html5
  implicit_shared_variable_access true

  def content
    @foo = "foo_from_widget"
  end
end
