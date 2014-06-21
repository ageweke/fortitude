describe "Fortitude void tags", :type => :system do
  def void_tag_class
    widget_class do
      tag :thevoid, :content_allowed => false

      def content
        thevoid
        thevoid(:foo => 'bar')
      end
    end
  end

  it "should not close void tags by default" do
    vtc = widget_class(:superclass => Fortitude::Widget) do
      tag :thevoid, :content_allowed => false

      def content
        thevoid
        thevoid(:foo => 'bar')
      end
    end

    expect(render(vtc)).to eq("<thevoid><thevoid foo=\"bar\">")
  end

  it "should not close void tags if asked not to" do
    klass = void_tag_class
    klass.close_void_tags false

    expect(render(klass)).to eq("<thevoid><thevoid foo=\"bar\">")
  end

  it "should close void tags if asked to" do
    klass = void_tag_class
    klass.close_void_tags true

    expect(render(klass)).to eq("<thevoid/><thevoid foo=\"bar\"/>")
  end

  it "should not affect non-void tags with no content" do
    klass = void_tag_class
    klass.class_eval do
      def content
        p
        p(:foo => "bar")
        div ""
        div(:foo => "bar")
        span { }
        span(:foo => "bar")
      end
    end
    klass.close_void_tags false

    expect(render(klass)).to eq("<p></p><p foo=\"bar\"></p><div></div><div foo=\"bar\"></div><span></span><span foo=\"bar\"></span>")
  end

  it "should not affect non-void tags with no content, and close_void_tags set to true" do
    klass = void_tag_class
    klass.class_eval do
      def content
        p
        p(:foo => "bar")
        div ""
        div(:foo => "bar")
        span { }
        span(:foo => "bar")
      end
    end
    klass.close_void_tags true

    expect(render(klass)).to eq("<p></p><p foo=\"bar\"></p><div></div><div foo=\"bar\"></div><span></span><span foo=\"bar\"></span>")
  end

  it "should not affect non-void tags with no content, and close_void_tags set to false" do
    klass = void_tag_class
    klass.class_eval do
      def content
        p
        p(:foo => "bar")
        div ""
        div(:foo => "bar")
        span { }
        span(:foo => "bar")
      end
    end
    klass.close_void_tags false

    expect(render(klass)).to eq("<p></p><p foo=\"bar\"></p><div></div><div foo=\"bar\"></div><span></span><span foo=\"bar\"></span>")
  end
end
