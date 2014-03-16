class Views::DataPassingSystemSpec::ParentToChildPassingPartialChild < Fortitude::Widget::Html5
  needs :foo

  def content
    p "foo: #{foo}"
  end
end
