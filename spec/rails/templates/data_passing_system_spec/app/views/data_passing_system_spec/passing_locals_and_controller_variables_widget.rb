class Views::DataPassingSystemSpec::PassingLocalsAndControllerVariablesWidget < Fortitude::Widgets::Html5
  needs :foo, :bar, :baz

  def content
    p "foo is: #{foo}"
    p "bar is: #{bar}"
    p "baz is: #{baz}"
  end
end
