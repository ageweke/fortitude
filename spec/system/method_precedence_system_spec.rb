describe "Fortitude method precedence", :type => :system do
  it "should have widget methods > need methods > helper methods > tag methods" do
    helpers_class = Class.new do
      def foo
        "helper_foo"
      end

      def bar
        "helper_bar"
      end

      def baz
        "helper_baz"
      end

      def quux
        "helper_quux"
      end
    end

    helpers_object = helpers_class.new

    wc = widget_class do
      tag :foo
      tag :bar
      tag :baz
      tag :quux

      helper :foo, :bar, :baz

      needs :foo => 'need_foo', :bar => 'need_bar'

      def foo
        "method foo"
      end

      def content
        text "foo: #{foo}, "
        text "bar: #{bar}, "
        text "baz: #{baz}, "
        quux
      end
    end

    expect(render(wc, :rendering_context => rc(
      :helpers_object => helpers_object))).to eq("foo: method foo, bar: need_bar, baz: helper_baz, <quux></quux>")
  end
end
