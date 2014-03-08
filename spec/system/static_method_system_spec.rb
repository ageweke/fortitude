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

  it "should not allow you to yield more than once from a method that's made static"
  it "should raise an error if you try to access a variable from within a method that's being made static"
end
