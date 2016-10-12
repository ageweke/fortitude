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
    expect(render(widget_class_with_content { p 'a<b' => 123 })).to eq("<p a&lt;b=\"123\"></p>")
  end

  it "should escape double quotes inside attribute values" do
    expect(render(widget_class_with_content { p :foo => 'a"b' })).to eq("<p foo=\"a&quot;b\"></p>")
  end

  it "should escape ampersands inside attribute values" do
    expect(render(widget_class_with_content { p :foo => 'a&b' })).to eq("<p foo=\"a&amp;b\"></p>")
  end

  it "should not escape less than signs, greater than signs, or single quotes inside attribute values" do
    expect(render(widget_class_with_content { p :foo => 'a<b>c\'d' })).to eq("<p foo=\"a<b>c'd\"></p>")
  end

  it "should escape direct arguments to tags" do
    expect(render(widget_class_with_content { p "a<b" })).to eq("<p>a&lt;b</p>")
  end

  it "should escape direct arguments to tags and attributes, even if all together" do
    expect(render(widget_class_with_content { p "a<b", 'b>a' => 'a&b' })).to eq("<p b&gt;a=\"a&amp;b\">a&lt;b</p>")
  end

  it "should still correctly escape very long strings" do
    very_long_string = "&" + ("a" * 300) + "<" + ("b" * 300) + ">" + ("c" * 300) + "&" + ("d" * 300) + "&" + ("e" * 300) + "\"";
    very_long_string_escaped = "&amp;" + ("a" * 300) + "&lt;" + ("b" * 300) + "&gt;" + ("c" * 300) + "&amp;" + ("d" * 300) + "&amp;" + ("e" * 300) + "&quot;"
    expect(render(widget_class_with_content { text very_long_string })).to eq(very_long_string_escaped)
  end
end
