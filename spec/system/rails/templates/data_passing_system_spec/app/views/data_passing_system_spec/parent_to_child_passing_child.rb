class Views::DataPassingSystemSpec::ParentToChildPassingChild < Fortitude::Widget
  needs :foo

  def content
    p "foo: #{foo.inspect}"
  end
end
