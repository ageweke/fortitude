require 'json'

class Views::DataPassingSystemSpec::WidgetCopiedVariables < Fortitude::Widget::Html5
  implicit_shared_variable_access true

  def content
    text ({ :widget_copied_variables => (instance_variables.map { |i| i.to_s }) }.to_json.html_safe)
  end
end
