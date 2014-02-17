describe "Fortitude assigns access", :type => :system do
  it "should expose assigns" do
    wc = widget_class do
      needs :foo, :bar
      def content
        text "assigns[:foo] = #{assigns[:foo]}, assigns[:bar] = #{assigns[:bar]}"
      end
    end

    expect(render(wc.new(:foo => 'the_foo', :bar => 'the_bar'))).to eq("assigns[:foo] = the_foo, assigns[:bar] = the_bar")
  end

  it "should include needs that are left as the default" do
    wc = widget_class do
      needs :foo, :bar => 'def_bar'
      def content
        text "assigns[:foo] = #{assigns[:foo]}, assigns[:bar] = #{assigns[:bar]}"
      end
    end

    expect(render(wc.new(:foo => 'the_foo'))).to eq("assigns[:foo] = the_foo, assigns[:bar] = def_bar")
  end

  it "should not include extra needs, by default" do
    wc = widget_class do
      needs :foo
      def content
        text "assigns[:foo] = #{assigns[:foo]}, assigns[:bar] = #{assigns[:bar]}"
      end
    end

    expect(render(wc.new(:foo => 'the_foo', :bar => 'the_bar'))).to eq("assigns[:foo] = the_foo, assigns[:bar] = ")
  end

  it "should include extra assigns, if we're using them" do
    wc = widget_class do
      extra_assigns :use
      needs :foo
      def content
        text "assigns[:foo] = #{assigns[:foo]}, assigns[:bar] = #{assigns[:bar]}"
      end
    end

    expect(render(wc.new(:foo => 'the_foo', :bar => 'the_bar'))).to eq("assigns[:foo] = the_foo, assigns[:bar] = the_bar")
  end

  it "should allow changing assigns, and always return the current value of the assign" do
    wc = widget_class do
      needs :foo
      def content
        text "foo = #{foo}, assigns[:foo] = #{assigns[:foo]}, "
        assigns[:foo] = "new_foo"
        text "now foo = #{foo}, assigns[:foo] = #{assigns[:foo]}"
      end
    end

    expect(render(wc.new(:foo => 'the_foo'))).to eq("foo = the_foo, assigns[:foo] = the_foo, now foo = new_foo, assigns[:foo] = new_foo")
  end
end
