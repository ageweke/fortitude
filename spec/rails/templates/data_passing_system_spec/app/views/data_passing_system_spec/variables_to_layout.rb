class Views::DataPassingSystemSpec::VariablesToLayout < Fortitude::Widgets::Html5
  needs :foo, :bar

  def content
    text "widget foo: #{foo}, widget bar: #{bar}"
  end
end
