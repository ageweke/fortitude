class Views::DataPassingSystemSpec::ImplicitErbToWidgetHandoffWidget < Fortitude::Widget
  implicit_shared_variable_access true

  def content
    p "widget foo: #{@foo}"
  end
end
