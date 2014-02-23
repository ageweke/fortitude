describe "Fortitude start/end comments support", :type => :system do
  EXPECTED_START_COMMENT_BOILERPLATE = "BEGIN Fortitude widget "
  EXPECTED_END_COMMENT_BOILERPLATE = "END Fortitude widget "

  it "should not add comments by default" do
    wc = widget_class do
      def content
        p "hi!"
      end
    end

    expect(render(wc)).to eq("<p>hi!</p>")
  end

  it "should add comments if asked to" do
    wc = widget_class do
      start_and_end_comments true

      def content
        p "hi!"
      end
    end

    expect(render(wc)).to eq("<!-- #{EXPECTED_START_COMMENT_BOILERPLATE}#{wc.name} --><p>hi!</p><!-- #{EXPECTED_END_COMMENT_BOILERPLATE}#{wc.name} -->")
  end

  it "should add passed assigns, including defaults" do
    wc = widget_class do
      start_and_end_comments true

      needs :foo, :bar => nil, :baz => 'def_baz', :quux => 'the_quux'

      def content
        p "hi"
      end
    end

    expect(render(wc.new(:foo => 'the_foo', :bar => /whatever/i, :quux => 'the_quux'))).to eq(
      "<!-- #{EXPECTED_START_COMMENT_BOILERPLATE}#{wc.name}: " +
      ":foo => \"the_foo\", :bar => /whatever/i, :baz => (DEFAULT) \"def_baz\", :quux => \"the_quux\"" +
      " --><p>hi</p><!-- #{EXPECTED_END_COMMENT_BOILERPLATE}#{wc.name} -->")
  end

  it "should include extra assigns if we're using them"
  it "should not display incredibly long assigns"
  it "should, by default, use #inspect, not #to_s, for assigns"
  it "should allow overriding the text returned for assigns"
  it "should order the comment text in whatever order the needs are declared"

  it "should escape any potentially invalid-comment text in assign keys"
  it "should escape any potentially invalid-comment text in assign values"
end
