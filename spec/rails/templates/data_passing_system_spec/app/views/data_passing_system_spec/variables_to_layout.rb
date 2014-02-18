class Views::DataPassingSystemSpec::VariablesToLayout < Fortitude::Widget
  needs :foo, :bar

  def content
    text "widget foo: #{foo}, widget bar: #{bar}"
  end
end
