describe "Fortitude needs", :type => :system do
  describe "inheritance" do
    it "should require needs from all superclasses" do
      grandparent = widget_class { needs :foo }
      parent = widget_class(:superclass => grandparent) { needs :bar }
      child = widget_class(:superclass => parent) do
        needs :baz
        def content
          text "foo: #{foo}, bar: #{bar}, baz: #{baz}"
        end
      end

      expect { child.new }.to raise_error(Fortitude::Errors::MissingNeed)
      expect { child.new(:foo => 'f') }.to raise_error(Fortitude::Errors::MissingNeed)
      expect { child.new(:foo => 'f', :bar => 'b') }.to raise_error(Fortitude::Errors::MissingNeed)
      expect(render(child.new(:foo => 'f', :bar => 'b', :baz => 'z'))).to eq("foo: f, bar: b, baz: z")
    end

    it "should let you add needs later, and it should apply to both that class and any subclasses" do
      parent = widget_class_with_content { text "parent" }
      child = widget_class(:superclass => parent) do
        needs :bar
        def content
          super
          text "; child: bar: #{bar}"
        end
      end

      expect(render(parent)).to eq("parent")
      expect(render(child.new(:bar => "the_bar"))).to eq("parent; child: bar: the_bar")

      parent.class_eval { needs :foo }
      child.class_eval do
        def content
          super
          text "; child: bar: #{bar}; foo: #{foo}"
        end
      end

      expect { parent.new }.to raise_error(Fortitude::Errors::MissingNeed)
      expect { child.new(:bar => 'the_bar') }.to raise_error(Fortitude::Errors::MissingNeed)

      expect(render(parent.new(:foo => "the_foo"))).to eq("parent")
      expect(render(child.new(:foo => "the_foo", :bar => "the_bar"))).to eq("parent; child: bar: the_bar; foo: the_foo")
    end
  end

  describe "defaults" do
    it "should allow supplying defaults, and allow overriding them" do
      c = widget_class do
        needs :foo, :bar => 'def_bar', :baz => 'def_baz'
        def content
          text "foo: #{foo}, bar: #{bar}, baz: #{baz}"
        end
      end

      expect { c.new }.to raise_error(Fortitude::Errors::MissingNeed)
      expect(render(c.new(:foo => 'the_foo'))).to eq("foo: the_foo, bar: def_bar, baz: def_baz")
      expect(render(c.new(:foo => 'the_foo', :baz => 'the_baz'))).to eq("foo: the_foo, bar: def_bar, baz: the_baz")
    end

    it "should inherit defaults properly" do
      parent = widget_class do
        needs :foo, :bar => 'def_bar', :baz => 'def_baz'
        def content
          text "foo: #{foo}, bar: #{bar}, baz: #{baz}"
        end
      end

      child = widget_class(:superclass => parent) do
        needs :baz => 'child_def_baz', :quux => 'child_quux'
        def content
          super
          text "; baz: #{baz}, quux: #{quux}"
        end
      end

      expect(render(parent.new(:foo => 'the_foo'))).to eq('foo: the_foo, bar: def_bar, baz: def_baz')
      expect { child.new }.to raise_error(Fortitude::Errors::MissingNeed)
      expect(render(child.new(:foo => 'the_foo'))).to eq('foo: the_foo, bar: def_bar, baz: child_def_baz; baz: child_def_baz, quux: child_quux')
    end

    it "should allow overriding a default with a requirement"
    it "should allow overriding a requirement with a default"
  end

  describe "extra assigns" do
    it "should, by default, ignore assigns it doesn't need"
    it "should fail if passed assigns it doesn't need, if asked to"
    it "should use extra assigns it doesn't need, if asked to"
  end
end
