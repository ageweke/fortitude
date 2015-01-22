describe "Fortitude tag rendering", :type => :system do
  def r(&block)
    render(widget_class_with_content(&block))
  end

  def should_render_to(value, &block)
    expect(r(&block)).to eq(value)
  end

  it "should allow passing numbers to a tag" do
    should_render_to("<p>123.45</p>") { p(123.45) }
  end

  it "should allow rendering nil to a tag" do
    should_render_to("<p></p>") { p(nil) }
  end

  it "should allow rendering nil via text" do
    should_render_to("") { text(nil) }
  end

  it "should allow rendering nil via rawtext" do
    should_render_to("") { rawtext(nil) }
  end

  it "should allow rendering nil as text, but still passing options" do
    should_render_to("<div class=\"foo\"></div>") { div(nil, :class => 'foo') }
  end

  it "should render an attribute mapped to nil as missing" do
    should_render_to("<p></p>") { p(:class => nil) }
    should_render_to("<p></p>") { p(:foo => { :bar => nil }) }
  end

  it "should render an attribute mapped to the empty string as the empty string" do
    should_render_to("<p class=\"\"></p>") { p(:class => '') }
    should_render_to("<p foo-bar=\"\"></p>") { p(:foo => { :bar => '' }) }
  end

  it "should render an attribute mapped to false as missing" do
    should_render_to("<p></p>") { p(:class => false) }
    should_render_to("<p></p>") { p(:foo => { :bar => false }) }
  end

  it "should render an attribute mapped to true as just a bare attribute" do
    should_render_to("<p class></p>") { p(:class => true) }
    should_render_to("<p foo-bar></p>") { p(:foo => { :bar => true }) }
  end

  it "should render an attribute mapped to the string 'true' as that string" do
    should_render_to("<p class=\"true\"></p>") { p(:class => 'true') }
    should_render_to("<p foo-bar=\"true\"></p>") { p(:foo => { :bar => 'true' }) }
  end

  it "should render a void tag correctly" do
    should_render_to("<hr>") { hr }
  end

  it "should not allow passing text content in a block to a tag that doesn't take content" do
    expect { r { br { text "hi" } } }.to raise_error(Fortitude::Errors::NoContentAllowed)
  end

  it "should render a non-self-closing tag correctly" do
    should_render_to("<script></script>") { script }
    should_render_to("<script></script>") { script { } }
    should_render_to("<script></script>") { script('') }
    should_render_to("<script></script>") { script('') { } }
    should_render_to("<script src=\"foo\"></script>") { script(:src => "foo") }
  end

  it "should quote HTML specs at you when you screw up" do
    expect { r { br { text "hi" } } }.to raise_error(Fortitude::Errors::NoContentAllowed, /THE_SPEC_FOR_BR/)
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

  it "should allow returning from within an element, and still render the close tags" do
    wc = widget_class do
      def content
        div {
          text "content_before"
          foo
          text "content_after"
        }
      end

      def foo
        p {
          text "foo_before"
          bar
          text "foo_after"
        }
      end

      def bar
        span {
          text "bar_first"
          a {
            text "bar_before"
            return
            text "bar_after"
          }
          text "bar_last"
        }
      end
    end

    expect(render(wc)).to eq("<div>content_before<p>foo_before<span>bar_first<a>bar_before</a></span>foo_after</p>content_after</div>")
  end

  it "should allow raising an exception from within an element, and still render the close tags" do
    wc = widget_class do
      def content
        div {
          text "content_before"
          foo
          text "content_after"
        }
      end

      def foo
        p {
          text "foo_before"
          bar
          text "foo_after"
        }
      end

      def bar
        span {
          text "bar_first"
          a {
            text "bar_before"
            raise "kaboom"
            text "bar_after"
          }
          text "bar_last"
        }
      end
    end

    widget = wc.new
    rendering_context = ::Fortitude::RenderingContext.new({ })
    expect { widget.render_to(rendering_context) }.to raise_error(/kaboom/)
    output = html_from(rendering_context)

    expect(output).to eq("<div>content_before<p>foo_before<span>bar_first<a>bar_before</a></span></p></div>")
  end

  it "should render a tag using a specific tag_* method" do
    should_render_to("<p>foo</p>") { tag_p "foo" }
  end

  it "should let you override a tag and use #super" do
    wc = widget_class do
      def p(data, options = { })
        text "before_p"
        super(data, { :bar => 'baz' }.merge(options))
        text("after_p")
      end

      def content
        text "yo"
        p "hello"
        text "bye"
      end
    end

    expect(render(wc)).to eq("yobefore_p<p bar=\"baz\">hello</p>after_pbye")
  end

  it "should let you override a tag and use #super, even if it's defined directly on that widget class" do
    wc = widget_class do
      tag :mytag

      def mytag(data, options = { })
        text "before_mytag"
        super(data, { :bar => 'baz' }.merge(options))
        text("after_mytag")
      end

      def content
        text "yo"
        mytag "hello"
        text "bye"
      end
    end

    expect(render(wc)).to eq("yobefore_mytag<mytag bar=\"baz\">hello</mytag>after_mytagbye")
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
    should_render_to("<hr class=\"foo\">") { hr 'class' => 'foo' }
  end

  it "should convert symbol attribute names to strings" do
    should_render_to("<hr class=\"foo\">") { hr :class => 'foo' }
  end

  it "should convert symbol attribute values to strings" do
    should_render_to("<hr class=\"foo\">") { hr 'class' => :foo }
  end

  it "should allow numbers for attribute names" do
    should_render_to("<hr 12345=\"foo\">") { hr 12345 => 'foo' }
  end

  it "should allow numbers for attribute values, and still quote them" do
    should_render_to("<hr class=\"12345\">") { hr 'class' => 12345 }
  end

  it "should escape attribute names" do
    should_render_to("<hr &lt;&amp;&quot;&gt;=\"foo\">") { hr '<&">' => "foo" }
  end

  it "should escape attribute values" do
    should_render_to("<hr class=\"&lt;&amp;&quot;&gt;\">") { hr :class => "<&\">" }
  end

  it "should separate multiple attributes with spaces" do
    result = r { hr 'class' => "foo", 'other' => "bar" }
    expect(result).to match(%r{^<hr .*\">$})
    expect(result).to match(%r{ class=\"foo\"})
    expect(result).to match(%r{ other=\"bar\"})
  end

  unless RUBY_VERSION =~ /^1\.8\./
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
      expected_string << ">"

      should_render_to(expected_string) { hr attributes }
    end
  end

  it "should render a tag given a block" do
    should_render_to("<p>hello, world</p>") { p { text "hello, world" } }
  end

  it "should render an empty tag given an empty block" do
    should_render_to("<p></p>") { p { } }
  end

  it "should render with both attributes and a block" do
    result = r { p(:class => 'foo', :bar => 'baz') { text "hello, world" } }
    expect(result).to match(%r{^<p .*\">hello, world</p>$})
    expect(result).to match(%r{ class=\"foo\"})
    expect(result).to match(%r{ bar=\"baz\"})
  end

  it "should render with both attributes and direct content" do
    result = r { p("hello, world", :class => 'foo', :bar => 'baz') }
    expect(result).to match(%r{^<p .*\">hello, world</p>$})
    expect(result).to match(%r{ class=\"foo\"})
    expect(result).to match(%r{ bar=\"baz\"})
  end

  it "should render with both direct content and a block" do
    should_render_to("<p>hello, worldbienvenue, le monde</p>") { p("hello, world") { text "bienvenue, le monde" } }
  end

  it "should render with both attributes and a block" do
    result = r { p(:class => :foo, :bar => :baz) { text "hello, world" } }
    expect(result).to match(%r{^<p .*\">hello, world</p>$})
    expect(result).to match(%r{ class=\"foo\"})
    expect(result).to match(%r{ bar=\"baz\"})
  end

  it "should render with attributes, direct content, and a block" do
    result = r { p("hello, world", :class => :foo, :bar => :baz) { text "bienvenue, le monde" } }
    expect(result).to match(%r{^<p .*\">hello, worldbienvenue, le monde</p>$})
    expect(result).to match(%r{ class=\"foo\"})
    expect(result).to match(%r{ bar=\"baz\"})
  end

  it "should render attribute values that are hashes as a sequence of prefixed attributes" do
    result = r { p :data => { :foo => 'bar', :bar => 'baz' } }
    expect(result).to match(%r{^<p .*\"></p>$})
    expect(result).to match(%r{ data-foo=\"bar\"})
    expect(result).to match(%r{ data-bar=\"baz\"})
  end

  it "should render an arbitrary object as an attribute key, escaping it" do
    foo = arbitrary_object_with_to_s("and&<>\"this")
    should_render_to("<p and&amp;&lt;&gt;&quot;this=\"bar\"></p>") { p foo => "bar" }
  end

  it "should render an arbitrary object as an attribute value, escaping it" do
    foo = arbitrary_object_with_to_s("and&<>\"this")
    should_render_to("<p foo=\"and&amp;&lt;&gt;&quot;this\"></p>") { p :foo => foo }
  end

  it "should render an arbitrary object as an attribute key nested in a hash, escaping it" do
    foo = arbitrary_object_with_to_s("and&<>\"this")
    should_render_to("<p data-and&amp;&lt;&gt;&quot;this=\"bar\"></p>") { p :data => { foo => "bar" } }
  end

  it "should render an arbitrary object as an attribute value nested in a hash, escaping it" do
    foo = arbitrary_object_with_to_s("and&<>\"this")
    should_render_to("<p data-and&amp;&lt;&gt;&quot;this=\"bar\"></p>") { p :data => { foo => "bar" } }
  end

  it "should allow an arbitrary object as an attribute key, mapping to a hash" do
    foo = arbitrary_object_with_to_s("and&<>\"this")
    result = r { p foo => { :foo => 'bar', :bar => 'baz' } }
    expect(result).to match(%r{^<p .*\"></p>$})
    expect(result).to match(%r{ and&amp;&lt;&gt;&quot;this-foo=\"bar\"})
    expect(result).to match(%r{ and&amp;&lt;&gt;&quot;this-bar=\"baz\"})
  end

  it "should allow multi-level hash nesting" do
    result = r { p :foo => { :bar => 'bar', :baz => { :a => 'xxx', 'b' => :yyy } } }
    expect(result).to match(%r{^<p .*\"></p>})
    expect(result).to match(%r{ foo-bar=\"bar\"})
    expect(result).to match(%r{ foo-baz-a=\"xxx\"})
    expect(result).to match(%r{ foo-baz-b=\"yyy\"})
  end

  it "should allow arrays as attribute values, separating elements with spaces" do
    should_render_to("<p foo=\"bar baz quux\"></p>") { p :foo => [ 'bar', 'baz', 'quux' ]}
  end

  it "should allow arrays as attribute values, calling #to_s on values in them" do
    quux = arbitrary_object_with_to_s("quux")
    should_render_to("<p foo=\"bar baz quux\"></p>") { p :foo => [ 'bar', :baz, quux ]}
  end
end
