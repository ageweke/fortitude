describe "Fortitude needs", :type => :system do
  def required
    Fortitude::Widget::REQUIRED_NEED
  end

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

      expect(grandparent.needs).to eq({ :foo => required })
      expect(parent.needs).to eq({ :foo => required, :bar => required })
      expect(child.needs).to eq({ :foo => required, :bar => required, :baz => required })
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
      expect(parent.needs).to eq({ })
      expect(child.needs).to eq({ :bar => required })

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

      expect(parent.needs).to eq(:foo => required)
      expect(child.needs).to eq(:foo => required, :bar => required)
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

      expect(c.needs).to eq(:foo => required, :bar => 'def_bar', :baz => 'def_baz')
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

      expect(parent.needs).to eq(:foo => required, :bar => 'def_bar', :baz => 'def_baz')
      expect(child.needs).to eq(:foo => required, :bar => 'def_bar', :baz => 'child_def_baz', :quux => 'child_quux')
    end

    it "should allow overriding a default with a requirement" do
      parent = widget_class do
        needs :foo, :bar => 'def_bar'
      end

      child = widget_class(:superclass => parent) do
        needs :bar
        def content
          text "foo: #{foo}, bar: #{bar}"
        end
      end

      expect { child.new(:foo => 'the_foo') }.to raise_error(Fortitude::Errors::MissingNeed)
      expect(render(child.new(:foo => 'the_foo', :bar => 'the_bar'))).to eq('foo: the_foo, bar: the_bar')

      expect(parent.needs).to eq(:foo => required, :bar => 'def_bar')
      expect(child.needs).to eq(:foo => required, :bar => required)
    end

    it "should allow overriding a requirement with a default" do
      parent = widget_class do
        needs :foo, :bar
      end

      child = widget_class(:superclass => parent) do
        needs :foo => 'def_foo', :bar => 'def_bar'
        def content
          text "foo: #{foo}, bar: #{bar}"
        end
      end

      expect(render(child.new)).to eq('foo: def_foo, bar: def_bar')
      expect(render(child.new(:bar => 'the_bar'))).to eq('foo: def_foo, bar: the_bar')

      expect(parent.needs).to eq(:foo => required, :bar => required)
      expect(child.needs).to eq(:foo => 'def_foo', :bar => 'def_bar')
    end
  end

  describe "extra assigns" do
    it "should, by default, ignore assigns it doesn't need" do
      c = widget_class do
        needs :foo
        def content
          bar_value = begin
            bar
          rescue => e
            e.class.name
          end

          text "foo: #{foo}, bar: #{bar_value}"
        end
      end

      expect(render(c.new(:foo => 'the_foo', :bar => 'the_bar'))).to eq('foo: the_foo, bar: NameError')
    end

    it "should ignore assigns it doesn't need, if told to" do
      c = widget_class do
        extra_assigns :ignore
        needs :foo
        def content
          bar_value = begin
            bar
          rescue => e
            e.class.name
          end

          text "foo: #{foo}, bar: #{bar_value}"
        end
      end

      expect(render(c.new(:foo => 'the_foo', :bar => 'the_bar'))).to eq('foo: the_foo, bar: NameError')
    end

    it "should fail if passed assigns it doesn't need, if asked to" do
      c = widget_class do
        extra_assigns :error
        needs :foo
        def content
          text "foo: #{foo}"
        end
      end

      expect { c.new(:foo => 'the_foo', :bar => 'the_bar') }.to raise_error(Fortitude::Errors::ExtraAssigns, /bar/i)
      expect(render(c.new(:foo => 'the_foo'))).to eq("foo: the_foo")
    end

    it "should use extra assigns it doesn't need, if asked to" do
      c = widget_class do
        extra_assigns :use
        needs :foo
        def content
          bar_value = begin
            bar
          rescue => e
            e.class.name
          end

          text "foo: #{foo}; bar: #{bar_value}"
        end
      end

      expect(render(c.new(:foo => 'the_foo'))).to eq('foo: the_foo; bar: NameError')
      expect(render(c.new(:foo => 'the_foo', :bar => 'the_bar'))).to eq('foo: the_foo; bar: the_bar')
    end
  end
end
