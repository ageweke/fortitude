describe "Fortitude::Widget#widget method", :type => :system do
  let(:child_widget_class) do
    widget_class do
      needs :value => nil

      def content
        p "child widget: #{value.inspect}"
      end
    end
  end

  def parent_widget_class(&block)
    out = widget_class do
      class << self
        attr_accessor :child_widget_class
      end

      def child_widget_class
        self.class.child_widget_class
      end

      define_method(:content, &block)
    end

    out.child_widget_class = child_widget_class
    out
  end

  it "should let you render one widget from another by specifying it as an instance" do
    expect(render(parent_widget_class { text "before"; widget child_widget_class.new; text "after" })).to eq(
      "before<p>child widget: nil</p>after")
  end

  it "should let you render one widget from another by specifying it as an instance, passing parameters" do
    expect(render(parent_widget_class { text "before"; widget child_widget_class.new(:value => 123); text "after" })).to eq(
      "before<p>child widget: 123</p>after")
  end

  it "should let you render one widget from another by specifying it as just a class" do
    expect(render(parent_widget_class { text "before"; widget child_widget_class; text "after" })).to eq(
      "before<p>child widget: nil</p>after")
  end

  it "should let you render one widget from another by specifying it as a class, and a hash of parameters" do
    expect(render(parent_widget_class { text "before"; widget child_widget_class, :value => 123; text "after" })).to eq(
      "before<p>child widget: 123</p>after")
  end

  it "should not let you specify anything but a Hash as the second parameter" do
    expect { render(parent_widget_class { text "before"; widget child_widget_class, 123; text "after" }) }.to raise_error
  end
end
