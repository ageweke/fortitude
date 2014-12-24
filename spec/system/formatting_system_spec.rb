describe "Fortitude formatting support", :type => :system do
  def should_format_to(text, &block)
    wc = widget_class do
      format_output true
    end

    wc.send(:define_method, :content, &block)
    actual = render(wc)
    expect(actual).to eq(text)
  end

  it "should add newlines around <div> and <p>" do
    should_format_to(%{<div>
  <p>
    yo!
  </p>
</div>}) { div { p { text "yo!" } } }
  end

  it "should not add newlines for <a>" do
    should_format_to(%{<a href="foo">yo!</a>}) { a "yo!", :href => "foo" }
  end

  it "should still close tags directly if it can" do
    should_format_to(%{<div></div>}) { div }
  end

  it "should put a non-newlined element inside a newlined element properly" do
    should_format_to(%{<div>
  <a class="bar">foo</a>
</div>}) { div { a "foo", :class => "bar" } }
  end

  it "should put a newlined element inside a non-newlined element properly" do
    should_format_to(%{<a class="foo">
<div class="bar">
  baz
</div>
</a>}) { a(:class => 'foo') { div(:class => 'bar') { text "baz" } } }
  end

  it "should format a nested combination properly" do
    should_format_to(%{<nav id="main-menu">
  <h1 id="brand">
    <a href="somewhere"><img src="an_img"></a>
  </h1>
</nav>}) do
      nav(:id => 'main-menu') do
        h1(:id => 'brand') do
          a :href => 'somewhere' do
            img :src => 'an_img'
          end
        end
      end
    end
  end

  it "should put the start and end tag of a block element nested properly even if there's nothing inside it" do
    should_format_to(%{<div class="foo">
  <div class="bar">
  </div>
</div>}) { div(:class => 'foo') { div(:class => 'bar') { } } }
  end

  it "should suppress all formatting inside <pre>" do
    should_format_to(%{<pre><p>hello
  world
there</p></pre>}) { pre { p "hello\n  world\nthere" } }
  end

  it "should suppress all formatting inside <pre> (complex example)" do
    should_format_to(%{<div>
  <pre><p>hello
  world
there</p><div><p>another here</p></div><p>yet another</p></pre>
</div>}) { div { pre { p "hello\n  world\nthere"; div { p "another here" }; p "yet another" } } }
  end

  it "should suppress all formatting inside <pre>, even with nested <pre> tags" do
    should_format_to(%{<div>
  <pre><p>hello
  world
there</p><pre><p>another
  here</p></pre><p>yet another</p></pre>
</div>}) { div { pre { p "hello\n  world\nthere"; pre { p "another\n  here" }; p "yet another" } } }
  end
end
