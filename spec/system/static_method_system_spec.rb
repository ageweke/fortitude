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

  it "should give you a good error if you try to make a method static before it's defined" do
    expect do
      widget_class do
        def content
          foo
        end

        static :foo

        def foo
          p "bar"
        end
      end
    end.to raise_error(NameError, /no method declared on this class with that name/mi)
  end

  it "should update the static definition of a method if static is called again" do
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
    wc.class_eval { static :content }
    expect(render(wc)).to eq('<p class="foo">bar: 23456</p><p>baz</p>')
    $global_value = 34567
    expect(render(wc)).to eq('<p class="foo">bar: 23456</p><p>baz</p>')
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
    $global_value = 34567
    expect(render(wc)).to eq('content before:34567foo before:12345yield inside:34567foo after:12345content after:34567')
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

    expect { wc.class_eval { static :foo }; render(wc) }.to raise_error(/yields more than once/i)
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

    e = capture_exception(Fortitude::Errors::DynamicAccessFromStaticMethod) { wc.class_eval { static :bar }; render(wc) }
    expect(e.widget.class).to be(wc)
    expect(e.static_method_name).to eq(:bar)
    expect(e.method_called).to eq(:foo)
  end

  def check_dynamic_raises(base_class, method_called, &block)
    subclass = Class.new(base_class)
    subclass.send(:define_method, :bar, &block)

    e = capture_exception(Fortitude::Errors::DynamicAccessFromStaticMethod) { subclass.static :bar; render(subclass) }
    expect(e.widget.class).to be(subclass)
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
    check_dynamic_raises(base_class, :shared_variables) { shared_variables }
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
    expect(render(wc.new(:foo => 23456))).to eq("foo: 23456bar!")
  end

  it "should allow disabling locale support" do
    $global_value = 12345
    wc = widget_class do
      def initialize(locale)
        @locale = locale
      end

      def widget_locale
        @locale
      end

      def content
        foo
      end

      def foo
        text "locale: #{widget_locale}, #{$global_value}"
      end

      static :foo, :locale_support => false
    end

    expect(render(wc.new(:en))).to eq("locale: en, 12345")
    $global_value = 23456
    expect(render(wc.new(:fr))).to eq("locale: en, 12345")
    expect(render(wc.new(:en))).to eq("locale: en, 12345")
  end

  describe "helper support" do
    before :each do
      @helpers_class = Class.new do
        def foo(x)
          "foo #{x} foo!"
        end
      end
      @helpers_object = @helpers_class.new

      @wc = widget_class do
        def content
          text "it is: #{foo('bar')}"
        end
      end
    end

    def do_render(widget_or_class, options = { })
      render(widget_or_class, { :rendering_context => rc(:helpers_object => @helpers_object) }.merge(options))
    end

    it "should allow static methods to access helpers by default" do
      expect(do_render(@wc)).to eq("it is: foo bar foo!")
      @wc.static :content
      expect(do_render(@wc)).to eq("it is: foo bar foo!")
      expect(do_render(@wc)).to eq("it is: foo bar foo!")
    end
  end

  describe "around_content support" do
    before :each do
      $global_value = 12345
      @wc = widget_class do
        around_content :ac

        def ac
          text "before #{$global_value}"
          yield
          text "after #{$global_value}"
        end

        def content
          text "this is content"
          sub
        end

        def sub
          text "this is sub #{$global_value}"
        end
      end
    end

    it "should not run around_content filters around a static method, if that method is not #content" do
      @wc.static :sub
      expect(render(@wc)).to eq("before 12345this is contentthis is sub 12345after 12345")
      $global_value = 23456
      expect(render(@wc)).to eq("before 23456this is contentthis is sub 12345after 23456")
    end

    it "should run around_content filters around a static method, if that method is #content" do
      @wc.static :content
      expect(render(@wc)).to eq("before 12345this is contentthis is sub 12345after 12345")
      $global_value = 23456
      expect(render(@wc)).to eq("before 23456this is contentthis is sub 12345after 23456")
    end
  end

  it "should still run the proper localized content methods even if #content, or one of them, is static" do
    $global_value = 12345
    wc = widget_class do
      use_localized_content_methods true

      def initialize(locale)
        self.widget_locale = locale
        super({ })
      end

      def localized_content_en
        text "hullo! #{$global_value}"
      end

      def localized_content_fr
        text "bonjour! #{$global_value}"
      end

      def content
        text "saluton! #{$global_value}"
      end

      attr_accessor :widget_locale
    end

    expect(render(wc.new(nil))).to eq("saluton! 12345")
    expect(render(wc.new(:en))).to eq("hullo! 12345")
    expect(render(wc.new(:fr))).to eq("bonjour! 12345")

    wc.static :localized_content_fr
    expect(render(wc.new(:fr))).to eq("bonjour! 12345")
    $global_value = 23456

    expect(render(wc.new(nil))).to eq("saluton! 23456")
    expect(render(wc.new(:en))).to eq("hullo! 23456")
    expect(render(wc.new(:fr))).to eq("bonjour! 12345")

    wc.static :content
    expect(render(wc.new(nil))).to eq("saluton! 23456")
    $global_value = 34567

    expect(render(wc.new(nil))).to eq("saluton! 23456")
    expect(render(wc.new(:en))).to eq("hullo! 34567")
    expect(render(wc.new(:fr))).to eq("bonjour! 12345")
  end

  describe "localization support" do
    it "should allow staticized methods to have different output per-locale" do
      $global_value = 12345
      wc = widget_class do
        def initialize(locale)
          @locale = locale
        end

        def widget_locale
          @locale
        end

        def content
          text "this is content in #{widget_locale} language #{$global_value}!"
        end
      end

      expect(render(wc.new(nil))).to eq("this is content in  language 12345!")
      expect(render(wc.new("en"))).to eq("this is content in en language 12345!")
      expect(render(wc.new("fr"))).to eq("this is content in fr language 12345!")

      $global_value = 23456
      wc.static :content

      expect(render(wc.new(nil))).to eq("this is content in  language 23456!")
      expect(render(wc.new("en"))).to eq("this is content in en language 23456!")
      expect(render(wc.new("fr"))).to eq("this is content in fr language 23456!")

      $global_value = 34567

      expect(render(wc.new(nil))).to eq("this is content in  language 23456!")
      expect(render(wc.new("en"))).to eq("this is content in en language 23456!")
      expect(render(wc.new("fr"))).to eq("this is content in fr language 23456!")
    end
  end
end
