describe "Fortitude basic operations", :type => :system do
  it "should render a widget with text" do
    expect(render(widget_class_with_content { text "hello, world" })).to eq("hello, world")
  end

  it "should render a widget with a tag" do
    expect(render(widget_class_with_content { p { text "hello, world" } })).to eq("<p>hello, world</p>")
  end
end
