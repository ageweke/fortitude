class Views::DataPassingSystemSpec::NilDataWidget < Fortitude::Widgets::Html5
  needs :foo, :bar

  def content
    p "foo is: #{foo.inspect}"
    p "bar is: #{bar.inspect}"
  end
end
