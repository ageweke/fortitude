describe "Fortitude inline-code support", :type => :system do
  it "should let you get a widget class back with .new_subclass" do
    wc = widget_class
    new_wc = wc.inline_subclass do
      p "hello, world"
    end
    expect(render(new_wc)).to eq("<p>hello, world</p>")
  end

  it "should let you pass assigns to the new subclass, and inherit settings of the parent" do
    wc = widget_class do
      start_and_end_comments true
      format_output true

      needs :name
    end

    new_wc = wc.inline_subclass do
      div {
        p "hello, #{name}"
      }
    end

    expect(render(new_wc.new(:name => 'julia'))).to eq(%{<!-- BEGIN (anonymous widget class) depth 0: :name => \"julia\" -->
<div>
  <p>hello, julia</p>
</div>
<!-- END (anonymous widget class) depth 0 -->})
  end

  it "should let you get rendered content back with .inline_html" do
    data = ::Fortitude::Widgets::Html5.inline_html do
      p "hello, world"
    end
    expect(data).to eq("<p>hello, world</p>")
  end

  it "should let you pass assigns to the new widget with .inline_html, and inherit settings of the parent" do
    wc = widget_class do
      start_and_end_comments true
      format_output true

      needs :name
    end

    content = wc.inline_html(:name => 'julia') do
      div {
        p "hello, #{name}"
      }
    end

    expect(content).to eq(%{<!-- BEGIN (anonymous widget class) depth 0: :name => \"julia\" -->
<div>
  <p>hello, julia</p>
</div>
<!-- END (anonymous widget class) depth 0 -->})
  end
end
