class Views::DataPassingSystemSpec::ParentToChildPassingChild < Fortitude::Widgets::Html5
  needs :foo

  def content
    p "foo: #{foo.inspect}"
  end
end
