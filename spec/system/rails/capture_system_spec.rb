describe "Rails capture support", :type => :rails do
  uses_rails_with_template :capture_system_spec

  it "should successfully capture a widget partial with capture { } in an ERb view" do
    expect_match('capture_widget_from_erb', %r{Widget text is:\s+<h3>\s*this is some_widget</h3>\s*END}mi)
  end

  it "should successfully capture an ERb partial with capture { } in a widget" do
    expect_match('capture_erb_from_widget', %r{Widget text is:\s+<h3>\s*this is some_erb_partial</h3>\s*END}mi)
  end

  it "should successfully capture a widget with capture { } in a widget"
  it "should be able to provide content in a widget with content_for"
  it "should be able to provide content in a widget with provide"
  it "should be able to retrieve stored content in a widget with content_for :name"
  it "should be able to retrieve stored content in a widget with yield :name"
end
