class Views::BasicRailsSystemSpec::PassingDataWidget < Fortitude::Widget
  needs :foo, :bar

  def content
    p "foo is: #{foo}"
    p "bar is: #{bar}"
  end
end
