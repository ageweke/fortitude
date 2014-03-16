class Views::DataPassingSystemSpec::ErbToParallelWidgetHandoffWidget < Fortitude::Widget::Html5
  def content
    p "widget foo: #{shared_variables[:foo]}"
  end
end
