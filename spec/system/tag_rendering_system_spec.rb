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

  it "should not allow passing text content in a block to a tag that doesn't take content" do
    expect { r { br { text "hi" } } }.to raise_error(Fortitude::Errors::NoContentAllowed)
  end

  it "should not allow passing element content in a block to a tag that doesn't take content" do
    expect { r { br { p } } }.to raise_error(Fortitude::Errors::NoContentAllowed)
  end

  it "should not allow passing text content to a tag that doesn't take content" do
    expect { r { br "hi" } }.to raise_error(Fortitude::Errors::NoContentAllowed)
  end

  it "should not allow passing text content to a tag that doesn't take content, even if it has attributes" do
    expect { r { br "hi", :class => 'yo' } }.to raise_error(Fortitude::Errors::NoContentAllowed)
  end

  it "should render a tag with direct text content correctly" do
    should_render_to("<p>hello, world</p>") { p "hello, world" }
  end

  it "should render a tag with numeric content correctly" do
    should_render_to("<p>12345</p>") { p 12345 }
  end

  def arbitrary_object_with_to_s(value)
    out = Object.new
    class << out
      attr_accessor :value

      def to_s
        @value
      end
    end
    out.value = value
    out
  end

  it "should render an arbitrary object as content, using #to_s, and escaping it" do
    foo = arbitrary_object_with_to_s("this is <>&\" foo!")
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

  it "should render with both attributes and direct content" do
    should_render_to("<p class=\"foo\" bar=\"baz\">hello, world</p>") { p("hello, world", :class => 'foo', :bar => 'baz') }
  end

  it "should render with both direct content and a block" do
    should_render_to("<p>hello, worldbienvenue, le monde</p>") { p("hello, world") { text "bienvenue, le monde" } }
  end

  it "should render with both attributes and a block" do
    should_render_to("<p class=\"foo\" bar=\"baz\">hello, world</p>") { p(:class => :foo, :bar => :baz) { text "hello, world" } }
  end

  it "should render with attributes, direct content, and a block" do
    should_render_to("<p class=\"foo\" bar=\"baz\">hello, worldbienvenue, le monde</p>") { p("hello, world", :class => :foo, :bar => :baz) { text "bienvenue, le monde" } }
  end

  it "should render attribute values that are hashes as a sequence of prefixed attributes" do
    should_render_to("<p data-foo=\"bar\" data-bar=\"baz\"/>") { p :data => { :foo => 'bar', :bar => 'baz' } }
  end

  it "should render an arbitrary object as an attribute key, escaping it" do
    foo = arbitrary_object_with_to_s("and&<>\"this")
    should_render_to("<p and&amp;&lt;&gt;&quot;this=\"bar\"/>") { p foo => "bar" }
  end

  it "should render an arbitrary object as an attribute value, escaping it" do
    foo = arbitrary_object_with_to_s("and&<>\"this")
    should_render_to("<p foo=\"and&amp;&lt;&gt;&quot;this\"/>") { p :foo => foo }
  end

  it "should render an arbitrary object as an attribute key nested in a hash, escaping it" do
    foo = arbitrary_object_with_to_s("and&<>\"this")
    should_render_to("<p data-and&amp;&lt;&gt;&quot;this=\"bar\"/>") { p :data => { foo => "bar" } }
  end

  it "should render an arbitrary object as an attribute value nested in a hash, escaping it" do
    foo = arbitrary_object_with_to_s("and&<>\"this")
    should_render_to("<p data-and&amp;&lt;&gt;&quot;this=\"bar\"/>") { p :data => { foo => "bar" } }
  end

  it "should allow an arbitrary object as an attribute key, mapping to a hash" do
    foo = arbitrary_object_with_to_s("and&<>\"this")
    should_render_to("<p and&amp;&lt;&gt;&quot;this-foo=\"bar\" and&amp;&lt;&gt;&quot;this-bar=\"baz\"/>") { p foo => { :foo => 'bar', :bar => 'baz' } }
  end

  it "should allow multi-level hash nesting" do
    should_render_to("<p foo-bar=\"bar\" foo-baz-a=\"xxx\" foo-baz-b=\"yyy\"/>") { p :foo => { :bar => 'bar', :baz => { :a => 'xxx', 'b' => :yyy } } }
  end

  it "should allow arrays as attribute values, separating elements with spaces" do
    should_render_to("<p foo=\"bar baz quux\"/>") { p :foo => [ 'bar', 'baz', 'quux' ]}
  end

  it "should allow arrays as attribute values, calling #to_s on values in them" do
    quux = arbitrary_object_with_to_s("quux")
    should_render_to("<p foo=\"bar baz quux\"/>") { p :foo => [ 'bar', :baz, quux ]}
  end
end
