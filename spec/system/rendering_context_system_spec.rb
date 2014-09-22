describe "Fortitude rendering context interactions", :type => :system do
  class RcSubclass < Fortitude::RenderingContext
    attr_reader :widget_calls

    def initialize(*args)
      super(*args)
      @widget_calls = [ ]
    end

    def start_widget!(widget)
      @widget_calls << [ :start, widget ]
    end

    def end_widget!(widget)
      @widget_calls << [ :end, widget ]
    end
  end

  def render(widget_or_class, options = { })
    @rc = RcSubclass.new({ })
    super(widget_or_class, options.merge(:rendering_context => @rc))
  end

  it "should return the parent widget properly" do
    child_widget_class = widget_class_with_content { p "child: #{rendering_context.parent_widget.some_method}" }
    parent_widget_class = widget_class do
      attr_accessor :child_widget_class

      def some_method
        "ahoy!"
      end

      def content
        p "foo"
        widget child_widget_class.new
        p "baz"
      end
    end

    pw = parent_widget_class.new
    pw.child_widget_class = child_widget_class
    expect(render(pw)).to eq("<p>foo</p><p>child: ahoy!</p><p>baz</p>")
  end

  it "should call start_widget! and end_widget! on the context when starting and ending a simple widget" do
    wc = widget_class_with_content { p "foo" }
    instance = wc.new
    expect(render(instance)).to eq("<p>foo</p>")
    expect(@rc.widget_calls).to eq([ [ :start, instance ], [ :end, instance ] ])
  end

  it "should call start_widget! and end_widget! in the right order with a deeply-nested example" do
    bottom = widget_class do
      needs :value
      def content
        text "bottom-#{value}"
      end
    end

    mid = widget_class do
      attr_accessor :bottom1, :bottom2
      def content
        widget bottom1 if bottom1
        widget bottom2 if bottom2
      end
    end

    top = widget_class do
      attr_accessor :mid1, :mid2
      def content
        widget mid1
        widget mid2
      end
    end

    bottom_a1 = bottom.new(:value => 12345)
    bottom_a2 = bottom.new(:value => 23456)
    bottom_b2 = bottom.new(:value => 34567)
    mid_a = mid.new
    mid_a.bottom1 = bottom_a1
    mid_a.bottom2 = bottom_a2
    mid_b = mid.new
    mid_b.bottom2 = bottom_b2
    top = top.new
    top.mid1 = mid_a
    top.mid2 = mid_b

    expect(render(top)).to eq("bottom-12345bottom-23456bottom-34567")
    expect(@rc.widget_calls).to eq([
      [ :start, top ],
      [ :start, mid_a ],
      [ :start, bottom_a1 ],
      [ :end, bottom_a1 ],
      [ :start, bottom_a2 ],
      [ :end, bottom_a2 ],
      [ :end, mid_a ],
      [ :start, mid_b ],
      [ :start, bottom_b2 ],
      [ :end, bottom_b2 ],
      [ :end, mid_b ],
      [ :end, top ]
      ])
  end
end
