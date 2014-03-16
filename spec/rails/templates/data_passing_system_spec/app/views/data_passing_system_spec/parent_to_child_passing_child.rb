class Views::DataPassingSystemSpec::ParentToChildPassingChild < Fortitude::Widget::Html5
  needs :foo

  def content
    p "foo: #{foo.inspect}"
  end
end
