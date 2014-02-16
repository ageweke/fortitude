describe "Fortitude tag rendering", :type => :system do
  def r(&block)
    render(widget_class_with_content(&block))
  end

  def should_render_to(value, &block)
    expect(r(&block)).to eq(value)
  end

  it "should render an empty tag correctly" do
    should_render_to("<hr/>") { hr }
  end

  it "should render a tag with direct text content correctly" do
    should_render_to("<p>hello, world</p>") { p "hello, world" }
  end

  it "should render a tag with numeric content correctly" do
    should_render_to("<p>12345</p>") { p 12345 }
  end

  it "should render an arbitrary object as content, using #to_s, and escaping it" do
    foo = Object.new
    class << foo
      def to_s
        "this is <>&\" foo!"
      end
    end

    should_render_to("<p>this is &lt;&gt;&amp;&quot; foo!</p>") { p foo }
  end

  it "should escape content directly passed to a tag" do
    should_render_to("<p>&lt;hello&gt; &quot;world&amp;</p>") { p "<hello> \"world&" }
  end

  it "should render a tag with an attribute correctly" do
    should_render_to("<hr class=\"foo\"/>") { hr 'class' => 'foo' }
  end

  it "should convert symbol attribute names to strings" do
    should_render_to("<hr class=\"foo\"/>") { hr :class => 'foo' }
  end

  it "should convert symbol attribute values to strings" do
    should_render_to("<hr class=\"foo\"/>") { hr 'class' => :foo }
  end

  it "should allow numbers for attribute names" do
    should_render_to("<hr 12345=\"foo\"/>") { hr 12345 => 'foo' }
  end

  it "should allow numbers for attribute values, and still quote them" do
    should_render_to("<hr class=\"12345\"/>") { hr 'class' => 12345 }
  end

  it "should escape attribute names" do
    should_render_to("<hr &lt;&amp;&quot;&gt;=\"foo\"/>") { hr '<&">' => "foo" }
  end

  it "should escape attribute values" do
    should_render_to("<hr class=\"&lt;&amp;&quot;&gt;\"/>") { hr :class => "<&\">" }
  end

  it "should separate multiple attributes with spaces" do
    should_render_to("<hr class=\"foo\" other=\"bar\"/>") { hr 'class' => "foo", 'other' => "bar" }
  end

  it "should render attributes in the order they're present in the Hash" do
    order = [ ]
    attributes = { }
    100.times do |index|
      name = "attr#{rand(1_000_000_000)}"
      attributes[name] = "order#{index}"
      order << name
    end

    expected_string = "<hr"
    order.each_with_index do |attrname, index|
      expected_string << " #{attrname}=\"order#{index}\""
    end
    expected_string << "/>"

    should_render_to(expected_string) { hr attributes }
  end

  it "should render a tag given a block" do
    should_render_to("<p>hello, world</p>") { p { text "hello, world" } }
  end

  it "should render an empty tag given an empty block" do
    should_render_to("<p></p>") { p { } }
  end

  it "should render with both attributes and a block" do
    should_render_to("<p class=\"foo\" bar=\"baz\">hello, world</p>") { p(:class => 'foo', :bar => 'baz') { text "hello, world" } }
  end
end
