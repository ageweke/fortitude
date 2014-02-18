describe "Fortitude formatting support", :type => :system do
  def should_format_to(text, &block)
    expect(render(widget_class_with_content(&block))).to eq(text)
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
    should_format_to(%{<div/>}) { div }
  end

  it "should put the start and end tag of a block element on the same line if there's nothing inside it" do
    should_format_to(%{<div class="foo"></div>}) { div(:class => 'foo') { } }
  end
end
