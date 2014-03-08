describe "Fortitude staticization behavior", :type => :system do
  it "should allow making a method static, and it should not change behavior ever" do
    $global_value = 12345
    wc = widget_class do
      def content
        p :class => 'foo' do
          text "bar: #{$global_value}"
        end
        p "baz"
      end

      static :content
    end

    expect(render(wc)).to eq('<p class="foo">bar: 12345</p><p>baz</p>')

    $global_value = 23456
    expect(render(wc)).to eq('<p class="foo">bar: 12345</p><p>baz</p>')
  end

  it "should allow making a method static twice, and it should not cause problems" do
    $global_value = 12345
    wc = widget_class do
      def content
        p :class => 'foo' do
          text "bar: #{$global_value}"
        end
        p "baz"
      end

      static :content
      static :content
    end

    expect(render(wc)).to eq('<p class="foo">bar: 12345</p><p>baz</p>')

    $global_value = 23456
    expect(render(wc)).to eq('<p class="foo">bar: 12345</p><p>baz</p>')
  end

  it "should allow you to yield from a method that's made static" do
    $global_value = 12345
    wc = widget_class do
      def content
        text "content before:#{$global_value}"
        foo do
          text "yield inside:#{$global_value}"
        end
        text "content after:#{$global_value}"
      end

      def foo
        text "foo before:#{$global_value}"
        yield
        text "foo after:#{$global_value}"
      end

      static :foo
    end

    expect(render(wc)).to eq('content before:12345foo before:12345yield inside:12345foo after:12345content after:12345')

    $global_value = 23456
    expect(render(wc)).to eq('content before:23456foo before:12345yield inside:23456foo after:12345content after:23456')
  end

  it "should not allow you to yield more than once from a method that's made static" do
    wc = widget_class do
      def content
        foo do
          text "yo"
        end
      end

      def foo
        text "one"
        yield
        text "two"
        yield
        text "three"
      end
    end

    expect { wc.class_eval { static :foo } }.to raise_error(/yields more than once/i)
  end

  it "should raise an error if you try to access a variable from within a method that's being made static" do
    wc = widget_class do
      needs :foo => 12345

      def content
        bar
      end

      def bar
        text "foo is: #{foo}"
      end
    end

    e = capture_exception(Fortitude::Errors::DynamicAccessFromStaticMethod) { wc.class_eval { static :bar } }
    expect(e.widget_class).to be(wc)
    expect(e.static_method_name).to eq(:bar)
    expect(e.method_called).to eq(:foo)
  end

  def check_dynamic_raises(base_class, method_called, &block)
    subclass = Class.new(base_class)
    subclass.send(:define_method, :bar, &block)

    e = capture_exception(Fortitude::Errors::DynamicAccessFromStaticMethod) { subclass.static :bar }
    expect(e.widget_class).to be(subclass)
    expect(e.static_method_name).to eq(:bar)
    expect(e.method_called).to eq(method_called)
  end

  it "should raise an error if you try to access dynamic data in other ways from within a method that's being made static" do
    base_class = widget_class do
      needs :foo => 12345

      def content
        bar
      end
    end

    check_dynamic_raises(base_class, :foo) { foo }
    check_dynamic_raises(base_class, :assigns) { assigns }
  end

  it "should allow static-izing a widget that has required needs" do
    wc = widget_class do
      needs :foo

      def content
        text "foo: #{foo}"
        bar
      end

      def bar
        text "bar!"
      end

      static :bar
    end

    expect(render(wc.new(:foo => 12345))).to eq("foo: 12345bar!")
  end
end
