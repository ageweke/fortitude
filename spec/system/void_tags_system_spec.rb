describe "Fortitude void tags", :type => :system do
  def void_tag_class
    widget_class do
      tag :thevoid, :content_allowed => false

      def content
        thevoid
      end
    end
  end

  it "should close void tags by default" do
    vtc = widget_class(:superclass => Fortitude::Widget) do
      tag :thevoid, :content_allowed => false

      def content
        thevoid
      end
    end

    expect(render(vtc)).to eq("<thevoid/>")
  end

  it "should not close void tags if asked not to" do
    klass = void_tag_class
    klass.close_void_tags false

    expect(render(klass)).to eq("<thevoid>")
  end

  it "should close void tags if asked to" do
    klass = void_tag_class
    klass.close_void_tags true

    expect(render(klass)).to eq("<thevoid/>")
  end

  it "should not affect non-void tags with no content" do
    klass = void_tag_class
    klass.class_eval do
      def content
        p
        div ""
        span { }
      end
    end
    klass.close_void_tags false

    expect(render(klass)).to eq("<p/><div></div><span></span>")
  end
end
