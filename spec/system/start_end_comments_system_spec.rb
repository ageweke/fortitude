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

  it "should not display extra assigns if we're not using them" do
    wc = widget_class do
      needs :foo
      start_and_end_comments true

      def content
        p "hi"
      end
    end

    expect(render(wc.new(:foo => 'bar', :bar => 'baz'))).to eq("<!-- #{EXPECTED_START_COMMENT_BOILERPLATE}#{wc.name}: " +
      ":foo => \"bar\" --><p>hi</p><!-- #{EXPECTED_END_COMMENT_BOILERPLATE}#{wc.name} -->")
  end

  it "should display extra assigns if we're using them" do
    wc = widget_class do
      needs :foo
      start_and_end_comments true
      extra_assigns :use

      def content
        p "hi"
      end
    end

    expect(render(wc.new(:foo => 'bar', :bar => 'baz'))).to eq("<!-- #{EXPECTED_START_COMMENT_BOILERPLATE}#{wc.name}: " +
      ":foo => \"bar\", :bar => \"baz\" --><p>hi</p><!-- #{EXPECTED_END_COMMENT_BOILERPLATE}#{wc.name} -->")
  end

  it "should not display all of the text of long assigns" do
    wc = widget_class do
      needs :foo
      start_and_end_comments true

      def content
        p "hi"
      end
    end

    assigns = { :foo => "a" * 1000 }
    text = render(wc.new(assigns))

    expect(text).to match(%r{^<!-- #{EXPECTED_START_COMMENT_BOILERPLATE}#{wc.name}: :foo => \"aaaaa})
    expect(text).to match(%r{aaa... --><p>hi</p><!-- #{EXPECTED_END_COMMENT_BOILERPLATE}#{wc.name} -->$})
    expect(text.length).to be < 500
    expect(text).not_to match("a" * 500)
  end

  it "should, by default, use #inspect, not #to_s, for assigns" do
    obj = Object.new
    class << obj
      def to_s
        "THIS IS TO_S"
      end

      def inspect
        "THIS IS INSPECT"
      end
    end

    wc = widget_class do
      needs :foo
      start_and_end_comments true

      def content
        p "hi"
      end
    end

    expect(render(wc.new(:foo => obj))).to eq("<!-- #{EXPECTED_START_COMMENT_BOILERPLATE}#{wc.name}: " +
      ":foo => THIS IS INSPECT --><p>hi</p><!-- #{EXPECTED_END_COMMENT_BOILERPLATE}#{wc.name} -->")
  end

  it "should allow overriding the text returned for assigns" do
    obj = Object.new
    class << obj
      def to_s
        "THIS IS TO_S"
      end

      def inspect
        "THIS IS INSPECT"
      end

      def to_fortitude_comment_string
        "THIS IS TO_FORTITUDE_COMMENT_STRING"
      end
    end

    wc = widget_class do
      needs :foo
      start_and_end_comments true

      def content
        p "hi"
      end
    end

    expect(render(wc.new(:foo => obj))).to eq("<!-- #{EXPECTED_START_COMMENT_BOILERPLATE}#{wc.name}: " +
      ":foo => THIS IS TO_FORTITUDE_COMMENT_STRING --><p>hi</p><!-- #{EXPECTED_END_COMMENT_BOILERPLATE}#{wc.name} -->")
  end

  it "should order the comment text in whatever order the needs are declared"
  it "should display the depth at which a widget is being rendered"

  it "should escape any potentially invalid-comment text in assign keys"
  it "should escape any potentially invalid-comment text in assign values"
end
