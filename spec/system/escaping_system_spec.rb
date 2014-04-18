describe "Fortitude escaping behavior", :type => :system do
  it "should escape text by default" do
    expect(render(widget_class_with_content { text "hi<>&\"' there" })).to match(/^hi&lt;&gt;&amp;&quot;&#(39|x27); there$/)
  end

  it "should not escape text tagged as .html_safe" do
    expect(render(widget_class_with_content { text "hi<>&\" there".html_safe })).to eq("hi<>&\" there")
  end

  it "should not escape text output with rawtext" do
    expect(render(widget_class_with_content { rawtext "hi<>&\" there" })).to eq("hi<>\&\" there")
  end

  it "should mark its output as html_safe" do
    expect(render(widget_class_with_content { text "hi < there"} )).to be_html_safe
  end

  it "should mark its output as html_safe, even if output as raw" do
    expect(render(widget_class_with_content { rawtext "hi < there"} )).to be_html_safe
  end

  it "should escape attribute names" do
    expect(render(widget_class_with_content { p 'a<b' => 123 })).to eq("<p a&lt;b=\"123\"/>")
  end

  it "should escape attribute values" do
    expect(render(widget_class_with_content { p :foo => 'a<b' })).to eq("<p foo=\"a&lt;b\"/>")
  end

  it "should escape direct arguments to tags" do
    expect(render(widget_class_with_content { p "a<b" })).to eq("<p>a&lt;b</p>")
  end

  it "should escape direct arguments to tags and attributes, even if all together" do
    expect(render(widget_class_with_content { p "a<b", 'b>a' => 'a&b' })).to eq("<p b&gt;a=\"a&amp;b\">a&lt;b</p>")
  end
end
