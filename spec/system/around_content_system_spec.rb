describe "Fortitude around_content operations", :type => :system do
  it "should operate with no around_content declared" do
    wc = widget_class do
      def content
        text "foo"
      end
    end

    expect(wc.send(:around_content_methods)).to eq([ ])
    expect(render(wc.new)).to eq("foo")
  end

  it "should run an around_content method around the content method" do
    wc = widget_class do
      def content
        text "content"
      end

      def around_content
        text "around_before"
        yield
        text "around_after"
      end

      around_content :around_content
    end

    expect(render(wc.new)).to eq("around_beforecontentaround_after")
  end

  it "should still let #content call #yield properly" do
    wc = widget_class do
      def content
        yield "aaa", "bbb"
        text "content"
      end

      def around_content
        text "around_before"
        yield
        text "around_after"
      end

      around_content :around_content
    end

    yielded = [ ]
    rendering_context = rc(:yield_block => lambda { |*args| yielded << args; "" })
    expect(render(wc.new, :rendering_context => rendering_context)).to eq("around_beforecontentaround_after")
    expect(yielded).to eq([ [ "aaa", "bbb" ] ])
  end

  it "should not run the content method or other around_content methods if you don't call yield" do
    wc = widget_class do
      def content
        text "content"
      end

      def around1
        text "around1_before"
        text "around1_after"
      end

      def around2
        text "around2_before"
        yield
        text "around2_after"
      end

      around_content :around1, :around2
    end

    expect(render(wc.new)).to eq("around1_beforearound1_after")
  end

  it "should work even if you declare around_content after the method you're calling" do
    wc = widget_class do
      around_content :around1

      def content
        text "content"
      end

      def around1
        text "around1_before"
        yield
        text "around1_after"
      end
    end

    expect(render(wc.new)).to eq("around1_beforecontentaround1_after")
  end

  it "should propagate an exception out of the content method, using normal Ruby semantics" do
    wc = widget_class do
      def mark(token)
        @marks ||= [ ]
        @marks << token
      end

      def marks
        @marks ||= [ ]
      end

      def content
        mark(:content)
        raise("kaboom")
      end

      def around1
        mark(:around1_before)
        yield
        mark(:around1_after)
      end

      def around2
        mark(:around2_before)
        yield
        mark(:around2_after)
      end

      around_content :around1, :around2
    end

    instance = wc.new
    expect { render(instance) }.to raise_error("kaboom")
    expect(instance.marks).to eq([ :around1_before, :around2_before, :content ])
  end

  it "should propagate an exception out of an around_content method, using normal Ruby semantics" do
    wc = widget_class do
      def mark(token)
        @marks ||= [ ]
        @marks << token
      end

      def marks
        @marks ||= [ ]
      end

      def content
        mark(:content)
      end

      def around1
        mark(:around1_before)
        yield
        mark(:around1_after)
      end

      def around2
        mark(:around2_before)
        raise("kaboom")
        yield
        mark(:around2_after)
      end

      around_content :around1, :around2
    end

    instance = wc.new
    expect { render(instance) }.to raise_error("kaboom")
    expect(instance.marks).to eq([ :around1_before, :around2_before ])
  end

  it "should run around_content methods in the order they are declared" do
    wc = widget_class do
      def around1
        text "around1_before"
        yield
        text "around1_after"
      end

      def around2
        text "around2_before"
        yield
        text "around2_after"
      end

      def content
        text "content"
      end

      around_content :around1
      around_content :around2
    end

    expect(render(wc.new)).to eq("around1_beforearound2_beforecontentaround2_afteraround1_after")
  end

  it "should run superclass around_content methods before subclass ones" do
    grandparent = widget_class do
      def gp1
        text "gp1_before"
        yield
        text "gp1_after"
      end

      def gp2
        text "gp2_before"
        yield
        text "gp2_after"
      end
    end

    parent = widget_class(:superclass => grandparent) do
      def p1
        text "p1_before"
        yield
        text "p1_after"
      end

      def p2
        text "p2_before"
        yield
        text "p2_after"
      end
    end

    child = widget_class(:superclass => parent) do
      def c1
        text "c1_before"
        yield
        text "c1_after"
      end

      def c2
        text "c2_before"
        yield
        text "c2_after"
      end

      def content
        text "content"
      end
    end

    # we do it in this order to make sure the order in which they're declared as around_content methods
    # doesn't make any difference
    parent.around_content :p2, :p1
    child.around_content :c1, :c2
    grandparent.around_content :gp1, :gp2

    expect(render(child.new)).to eq("gp1_beforegp2_beforep2_beforep1_beforec1_beforec2_beforecontentc2_afterc1_afterp1_afterp2_aftergp2_aftergp1_after")
  end

  it "should allow two child classes to both inherit around_content methods of a parent, but add their own ones, as well" do
    parent = widget_class do
      def p1
        text "p1_before"
        yield
        text "p1_after"
      end

      def p2
        text "p2_before"
        yield
        text "p2_after"
      end

      around_content :p1, :p2
    end

    c1 = widget_class(:superclass => parent) do
      def c1a1
        text "c1a1_before"
        yield
        text "c1a1_after"
      end

      def c1a2
        text "c1a2_before"
        yield
        text "c1a2_after"
      end

      def content
        text "content"
      end

      around_content :c1a1, :c1a2
    end

    c2 = widget_class(:superclass => parent) do
      def c2a1
        text "c2a1_before"
        yield
        text "c2a1_after"
      end

      def c2a2
        text "c2a2_before"
        yield
        text "c2a2_after"
      end

      def content
        text "content"
      end

      around_content :c2a1, :c2a2
    end

    expect(render(c1.new)).to eq("p1_beforep2_beforec1a1_beforec1a2_beforecontentc1a2_afterc1a1_afterp2_afterp1_after")
    expect(render(c2.new)).to eq("p1_beforep2_beforec2a1_beforec2a2_beforecontentc2a2_afterc2a1_afterp2_afterp1_after")
  end
end
