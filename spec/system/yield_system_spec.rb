describe "Fortitude widgets and 'yield'", :type => :system do
  it "should call the block passed to the constructor when you call 'yield' from #content" do
    wc = widget_class do
      def content
        text "before"
        yield
        text "after"
      end
    end

    expect(render(wc.new { |widget| widget.text "middle" })).to eq("beforemiddleafter")
  end

  it "should raise a clear error if you try to 'yield' from #content and there is no block passed" do
    wc = widget_class do
      def content
        text "before"
        yield
        text "after"
      end
    end

    instance = wc.new
    e = capture_exception(::Fortitude::Errors::NoBlockToYieldTo) { render(instance) }
    expect(e.message).to match(/#{Regexp.escape(instance.to_s)}/)
    expect(e.widget).to eq(instance)
  end

  it "should allow you to pass the block from #content to another method and run it from there just fine" do
    wc = widget_class do
      def content(&block)
        text "before"
        foo(&block)
        text "after"
      end

      def foo
        text "inner_before"
        yield
        text "inner_after"
      end
    end

    expect(render(wc.new { |widget| widget.text "middle" })).to eq("beforeinner_beforemiddleinner_afterafter")
  end

  it "should allow you to call that same block using #yield_from_widget in #content" do
    wc = widget_class do
      def content
        text "before"
        yield_from_widget
        text "after"
      end
    end

    expect(render(wc.new { |widget| widget.text "middle" })).to eq("beforemiddleafter")
  end

  it "should allow you to call that same block using #yield_from_widget in some other method, too" do
    wc = widget_class do
      def content
        text "before"
        foo
        text "after"
      end

      def foo
        text "inner_before"
        yield_from_widget
        text "inner_after"
      end
    end

    expect(render(wc.new { |widget| widget.text "middle" })).to eq("beforeinner_beforemiddleinner_afterafter")
  end

  it "should allow you to pass a block to #widget, and it should work the same way as passing it to the constructor" do
    wc_sub = widget_class do
      def content
        text "inner_before"
        yield
        text "inner_after"
      end
    end

    wc = widget_class do
      cattr_accessor :other_widget_class

      def content
        text "before"
        widget(self.class.other_widget_class) { text "middle"  }
        text "after"
      end
    end

    wc.other_widget_class = wc_sub
    expect(render(wc.new)).to eq("beforeinner_beforemiddleinner_afterafter")
  end

  it "should allow you to pass a block to #widget, and it should work the same way as passing it to the constructor, even if #widget is given a fully-intantiated widget" do
    wc_sub = widget_class do
      def content
        text "inner_before"
        yield
        text "inner_after"
      end
    end

    wc = widget_class do
      cattr_accessor :other_widget_class

      def content
        text "before"
        sub_widget = self.class.other_widget_class.new
        widget(sub_widget) { text "middle"  }
        text "after"
      end
    end

    wc.other_widget_class = wc_sub
    expect(render(wc.new)).to eq("beforeinner_beforemiddleinner_afterafter")
  end

  it "should use the block passed to #widget in preference to the one in the constructor, if both are passed" do
    wc_sub = widget_class do
      def content
        text "inner_before"
        yield
        text "inner_after"
      end
    end

    wc = widget_class do
      cattr_accessor :other_widget_class

      def content
        text "before"
        sub_widget = self.class.other_widget_class.new { text "foobar" }
        widget(sub_widget) { text "middle"  }
        text "after"
      end
    end

    wc.other_widget_class = wc_sub
    expect(render(wc.new)).to eq("beforeinner_beforemiddleinner_afterafter")
  end

  it "should use the block passed to the constructor in preference to the layout, if both exist" do
    the_rc = rc(:yield_block => lambda { raise "kaboomba" })

    wc = widget_class do
      def content
        text "before"
        yield
        text "after"
      end
    end

    expect(render(wc.new { |widget| widget.text "middle" }, :rendering_context => the_rc)).to eq("beforemiddleafter")
  end

  it "should use the block passed to #content in preference to the one from the constructor or the layout" do
    the_rc = rc(:yield_block => lambda { raise "kaboomba" })

    wc_sub = widget_class do
      def content
        text "inner_before"
        yield
        text "inner_after"
      end
    end

    wc = widget_class do
      cattr_accessor :other_widget_class

      def content
        text "before"
        other = self.class.other_widget_class.new { text "foobar" }
        widget(other) { text "middle" }
        text "after"
      end
    end

    wc.other_widget_class = wc_sub

    expect(render(wc.new { |widget| widget.text "constructor" }, :rendering_context => the_rc)).to eq("beforeinner_beforemiddleinner_afterafter")
  end
end
