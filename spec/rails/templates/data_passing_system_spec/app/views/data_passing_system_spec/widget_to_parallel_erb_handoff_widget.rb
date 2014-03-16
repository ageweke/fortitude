class Views::DataPassingSystemSpec::WidgetToParallelErbHandoffWidget < Fortitude::Widget::Html5
  def content
    shared_variables[:foo] = 'foo_from_widget'
  end
end
