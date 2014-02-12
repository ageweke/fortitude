class Views::DataPassingSystemSpec::WidgetToParallelErbHandoffWidget < Fortitude::Widget
  def content
    shared_variables[:foo] = 'foo_from_widget'
  end
end
