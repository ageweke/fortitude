class Views::DataPassingSystemSpec::ParentToChildPassingPartialChild < Fortitude::Widget
  needs :foo

  def content
    p "foo: #{foo}"
  end
end
