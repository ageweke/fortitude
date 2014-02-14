describe "Fortitude Erector compatibility", :type => :system do
  it "should allow implicit long-distance access to controller variables, if asked to" do
    ivars[:foo] = "the_foo"
    ivars[:bar] = "the_bar"

    superclass = widget_class
    subclass = widget_class(:superclass => superclass) do
      implicit_shared_variable_access true

      def content
        text "foo: #{@foo}, "
        text "bar: #{@bar}"
        @baz = "widget_baz"
      end
    end

    expect(render(subclass)).to eq("foo: the_foo, bar: the_bar")
    expect(ivars[:baz]).to eq("widget_baz")
  end

  describe "@foo variable access" do
    it "should not allow local access to needs via @foo, by default" do
      wc = widget_class do
        needs :foo
        def content
          text "foo: #{@foo.inspect}"
        end
      end

      expect(render(wc.new(:foo => 'the_foo'))).to eq('foo: nil')
    end

    it "should not allow local access to needs via @foo, if turned off" do
      wc = widget_class do
        use_instance_variables_for_assigns false
        needs :foo
        def content
          text "foo: #{@foo.inspect}"
        end
      end

      expect(render(wc.new(:foo => 'the_foo'))).to eq('foo: nil')
    end

    it "should allow local access to needs via @foo, if asked to" do
      wc = widget_class do
        use_instance_variables_for_assigns true
        needs :foo
        def content
          text "foo: #{@foo}"
        end
      end

      expect(render(wc.new(:foo => 'the_foo'))).to eq('foo: the_foo')
    end
  end

  describe "non-needed variables" do
    it "should allow local access to non-needed passed variables via @foo, if asked to" do
      wc = widget_class do
        extra_assigns :use
        use_instance_variables_for_assigns true
        needs :foo
        def content
          text "foo: #{@foo}, "
          text "bar: #{@bar}"
        end
      end
      expect(render(wc.new(:foo => "the_foo", :bar => "the_bar"))).to eq("foo: the_foo, bar: the_bar")
    end

    it "should allow local access to non-needed passed variables via method, if asked to" do
      wc = widget_class do
        extra_assigns :use
        needs :foo
        def content
          text "foo: #{foo}, "
          text "bar: #{bar}"
        end
      end
      expect(render(wc.new(:foo => "the_foo", :bar => "the_bar"))).to eq("foo: the_foo, bar: the_bar")
    end
  end
end
