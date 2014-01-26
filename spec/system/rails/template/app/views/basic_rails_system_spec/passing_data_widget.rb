class Views::BasicRailsSystemSpec::PassingDataWidget < Fortitude::Widget
  needs :foo, :bar

  def content
    p "Foo is: #{foo}"
    p "Bar is: #{bar}"
  end
end
