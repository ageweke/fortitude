describe "Fortitude start/end comments support", :type => :system do
  def eb(widget_class)
    "BEGIN Fortitude widget #{widget_class.name}"
  end

  def ee(widget_class)
    "END Fortitude widget #{widget_class.name}"
  end

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

    expect(render(wc)).to eq("<!-- #{eb(wc)} --><p>hi!</p><!-- #{ee(wc)} -->")
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
      "<!-- #{eb(wc)}: " +
      ":foo => \"the_foo\", :bar => /whatever/i, :baz => (DEFAULT) \"def_baz\", :quux => \"the_quux\"" +
      " --><p>hi</p><!-- #{ee(wc)} -->")
  end

  it "should not display extra assigns if we're not using them" do
    wc = widget_class do
      needs :foo
      start_and_end_comments true

      def content
        p "hi"
      end
    end

    expect(render(wc.new(:foo => 'bar', :bar => 'baz'))).to eq("<!-- #{eb(wc)}: " +
      ":foo => \"bar\" --><p>hi</p><!-- #{ee(wc)} -->")
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

    expect(render(wc.new(:foo => 'bar', :bar => 'baz'))).to eq("<!-- #{eb(wc)}: " +
      ":foo => \"bar\", :bar => \"baz\" --><p>hi</p><!-- #{ee(wc)} -->")
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

    expect(text).to match(%r{^<!-- #{eb(wc)}: :foo => \"aaaaa})
    expect(text).to match(%r{aaa... --><p>hi</p><!-- #{ee(wc)} -->$})
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

    expect(render(wc.new(:foo => obj))).to eq("<!-- #{eb(wc)}: " +
      ":foo => THIS IS INSPECT --><p>hi</p><!-- #{ee(wc)} -->")
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

    expect(render(wc.new(:foo => obj))).to eq("<!-- #{eb(wc)}: " +
      ":foo => THIS IS TO_FORTITUDE_COMMENT_STRING --><p>hi</p><!-- #{ee(wc)} -->")
  end

  it "should order the comment text in whatever order the needs are declared" do
    needed = [ ]
    5.times { needed << "need#{rand(1_000_000_000)}".to_sym }
    needed = needed.shuffle

    wc = widget_class do
      start_and_end_comments true

      def content
        p "hi"
      end
    end

    remaining_needed = needed.dup
    while remaining_needed.length > 0
      this_slice = remaining_needed.shift(rand(3))
      wc.needs *this_slice
    end

    params = { }
    needed.shuffle.each { |n| params[n] = "value-#{n}" }

    text = render(wc.new(params))

    expected_output = "<!-- #{eb(wc)}: "
    expected_output << needed.map do |n|
      ":#{n} => \"value-#{n}\""
    end.join(", ")
    expected_output << " --><p>hi</p><!-- #{ee(wc)} -->"
  end

  it "should display the depth at which a widget is being rendered" do

  end

  BAD_VALUES = [ ">foo", "fo -- bar", "--", "->bar", "baz-" ]

  BAD_VALUES.each do |bad_value|
    it "should escape any potentially invalid-comment text in assign values, like #{bad_value.inspect}" do
      wc = widget_class do
        needs :foo
        start_and_end_comments true

        def content
          p "hi"
        end
      end

      instance = wc.new(:foo => bad_value)
      text = render(instance)
      expect(text).to match(%r{^<!-- #{eb(wc)}: :foo => (.*) --><p>hi</p><!-- #{ee(wc)} -->$})
      data = $1
      $stderr.puts data
    end
  end
end
