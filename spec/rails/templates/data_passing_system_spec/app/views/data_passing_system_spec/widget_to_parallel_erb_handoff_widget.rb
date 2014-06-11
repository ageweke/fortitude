class Views::DataPassingSystemSpec::WidgetToParallelErbHandoffWidget < Fortitude::Widgets::Html5
  def content
    shared_variables[:foo] = 'foo_from_widget'
  end
end
