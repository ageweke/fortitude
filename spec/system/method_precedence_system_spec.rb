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

  it "should let you override 'needs' methods in superclasses, and have them still apply in subclasses" do
    wc_parent = widget_class do
      needs :foo, :bar => 'default_bar'

      def foo
        "pre#{super}post"
      end

      def content
        text "parent: foo: #{foo}, bar: #{bar}"
      end
    end

    wc_child = widget_class(:superclass => wc_parent) do
      def content
        text "child: foo: #{foo}, bar: #{bar}"
      end
    end

    expect(render(wc_child.new(:foo => 'supplied_foo'))).to eq("child: foo: presupplied_foopost, bar: default_bar")
  end
end
