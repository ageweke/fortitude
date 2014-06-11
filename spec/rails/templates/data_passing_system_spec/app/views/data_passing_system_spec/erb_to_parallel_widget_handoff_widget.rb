class Views::DataPassingSystemSpec::ErbToParallelWidgetHandoffWidget < Fortitude::Widgets::Html5
  def content
    p "widget foo: #{shared_variables[:foo]}"
  end
end
