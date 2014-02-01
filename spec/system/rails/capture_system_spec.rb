describe "Rails capture support", :type => :rails do
  uses_rails_with_template :capture_system_spec

  it "should successfully capture a widget partial with capture { } in an ERb view"
  it "should successfully capture an ERb partial with capture { } in a widget"
  it "should be able to provide content in a widget with content_for"
  it "should be able to provide content in a widget with provide"
  it "should be able to retrieve stored content in a widget with content_for :name"
  it "should be able to retrieve stored content in a widget with yield :name"
end
