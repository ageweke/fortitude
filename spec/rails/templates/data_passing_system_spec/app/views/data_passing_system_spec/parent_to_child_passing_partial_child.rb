class Views::DataPassingSystemSpec::ParentToChildPassingPartialChild < Fortitude::Widgets::Html5
  needs :foo

  def content
    p "foo: #{foo}"
  end
end
