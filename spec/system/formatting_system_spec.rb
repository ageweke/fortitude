describe "Fortitude formatting support", :type => :system do
  it "should format a very simple example correctly" do
    expect(render(widget_class_with_content { div { p { text "yo!" } } })).to eq("XXX")
  end
end
