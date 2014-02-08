class Views::DataPassingSystemSpec::ErbToParallelWidgetHandoffWidget < Fortitude::Widget
  def content
    p "widget foo: #{shared_variables[:foo]}"
  end
end
