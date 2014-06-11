class Views::DataPassingSystemSpec::PassingLocalsWidget < Fortitude::Widgets::Html5
  needs :foo, :bar

  def content
    p "foo is: #{foo}"
    p "bar is: #{bar}"
  end
end
