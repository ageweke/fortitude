class Views::DataPassingSystemSpec::ImplicitErbToWidgetHandoffWidget < Fortitude::Widget
  implicit_shared_variable_access

  def content
    p "widget foo: #{@foo}"
  end
end
