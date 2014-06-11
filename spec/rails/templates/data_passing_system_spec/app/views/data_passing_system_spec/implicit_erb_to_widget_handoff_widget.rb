class Views::DataPassingSystemSpec::ImplicitErbToWidgetHandoffWidget < Fortitude::Widgets::Html5
  implicit_shared_variable_access true

  def content
    p "widget foo: #{@foo}"
  end
end
