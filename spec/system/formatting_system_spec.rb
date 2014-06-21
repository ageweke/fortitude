describe "Fortitude formatting support", :type => :system do
  def should_format_to(text, &block)
    wc = widget_class do
      format_output true
    end

    wc.send(:define_method, :content, &block)
    expect(render(wc)).to eq(text)
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
    <a href="somewhere"><img src="an_img"/></a>
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
end
