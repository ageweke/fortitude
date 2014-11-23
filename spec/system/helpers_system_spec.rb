describe "Fortitude helper support", :type => :system do
  before :each do
    @output_buffer = ""
    @output_buffer_holder_class = Class.new do
      attr_accessor :output_buffer
    end
    @output_buffer_holder = @output_buffer_holder_class.new
    @output_buffer_holder.output_buffer = @output_buffer

    @helpers_class = Class.new do
      attr_accessor :output_buffer_holder

      def helper1
        "this is helper1"
      end

      def helper2(input)
        "this is #{input} helper2"
      end

      def helper3(input)
        output_buffer << "this is #{input} helper3"
      end

      def helper4(arg)
        result = yield(arg)
        "foo #{result} bar"
      end

      def p(input)
        "pp#{input}pp"
      end

      def kaboom
        raise "kaboom!"
      end

      def output_buffer
        @output_buffer_holder.output_buffer
      end
    end

    @helpers_object = @helpers_class.new
    @helpers_object.output_buffer_holder = @output_buffer_holder
  end

  def render(widget_or_class, options = { })
    @output_buffer.replace("")
    super(widget_or_class, { :rendering_context => rc(
      :helpers_object => @helpers_object, :output_buffer_holder => @output_buffer_holder) }.merge(options))
  end

  describe "manual invocation of helpers using #invoke_helper" do
    it "should work for a very simple helper, without arguments" do
      expect(render(widget_class_with_content { s = invoke_helper(:helper1); text s })).to eq("this is helper1")
    end

    it "should allow passing arguments" do
      expect(render(widget_class_with_content { s = invoke_helper(:helper2, 'foo'); text s })).to eq("this is foo helper2")
    end

    it "should work even if automatic_helper_access is off" do
      wc = widget_class do
        automatic_helper_access false
        def content
          text invoke_helper(:helper1)
        end
      end

      expect(render(wc)).to eq("this is helper1")
    end

    it "should allow passing a block" do
      expect(render(widget_class_with_content { text invoke_helper(:helper4, "b") { |a| "x#{a}x" } })).to eq("foo xbx bar")
    end

    it "should return an exception properly" do
      expect { render(widget_class_with_content { invoke_helper(:kaboom) }) }.to raise_error(/kaboom!/i)
    end

    it "should allow calling a helper that outputs" do
      expect(render(widget_class_with_content { invoke_helper(:helper3, "aaa") })).to eq("this is aaa helper3")
    end

    it "should allow calling a method that's overridden on Widget" do
      expect(render(widget_class_with_content { text invoke_helper(:p, "a") })).to eq("ppapp")
    end
  end

  it "should, by default, allow automatic access to helpers" do
    expect(render(widget_class_with_content { text "helper1: #{helper1}" })).to eq("helper1: this is helper1")
    expect(render(widget_class_with_content { text "helper2: #{helper2("yo")}" })).to eq("helper2: this is yo helper2")
    expect(render(widget_class_with_content { helper3("ho") })).to eq("this is ho helper3")
  end

  it "should indicate that it responds to helpers using respond_to? for automatic helper methods" do
    expect(render(widget_class_with_content { text "respond_to helper1: #{respond_to?(:helper1)}" } )).to eq("respond_to helper1: true")
    expect(render(widget_class_with_content { text "respond_to helper2: #{respond_to?(:helper2)}" } )).to eq("respond_to helper2: true")
    expect(render(widget_class_with_content { text "respond_to helper3: #{respond_to?(:helper3)}" } )).to eq("respond_to helper3: true")
  end

  it "should not allow automatic access to helpers if we say not to" do
    wc = widget_class do
      automatic_helper_access false
      def content
        helper1_value = begin
          helper1
        rescue => e
          e.class.name
        end

        helper2_value = begin
          helper2("foo")
        rescue => e
          e.class.name
        end

        helper3_value = begin
          helper3("bar")
        rescue => e
          e.class.name
        end

        text "helper1: #{helper1_value}, helper2: #{helper2_value}, helper3: #{helper3_value}"
      end
    end

    expect(render(wc)).to eq("helper1: NameError, helper2: NoMethodError, helper3: NoMethodError")
  end

  it "should allow manually declaring helpers" do
    wc = widget_class do
      automatic_helper_access false
      helper :helper1, :helper3
      def content
        helper2_value = begin
          helper2("foo")
        rescue => e
          e.class.name
        end

        text "helper1: #{helper1}, helper2: #{helper2_value}, helper3: "
        helper3("hi")
      end
    end

    expect(render(wc)).to eq("helper1: this is helper1, helper2: NoMethodError, helper3: this is hi helper3")
  end

  it "should allow overriding a manually-declared helper, and allow use of #super" do
    wc = widget_class do
      automatic_helper_access false
      helper :helper1

      def helper1
        "xx" + super + "yy"
      end

      def content
        text "helper1: #{helper1}"
      end
    end

    expect(render(wc)).to eq("helper1: xxthis is helper1yy")
  end

  it "should allow overriding a helper accessed using automatic_helper_access, and allow use of #super" do
    wc = widget_class do
      def helper1
        "xx" + super + "yy"
      end

      def content
        text "helper1: #{helper1}"
      end
    end

    expect(render(wc)).to eq("helper1: xxthis is helper1yy")
  end

  it "should allow transforming helpers that return to helpers that output" do
    wc = widget_class do
      helper :helper1, :transform => :output_return_value

      def content
        text "helper1: "
        helper1
      end
    end

    expect(render(wc)).to eq("helper1: this is helper1")
  end

  it "should allow transforming helpers that output to helpers that return" do
    wc = widget_class do
      helper :helper3, :transform => :return_output

      def content
        helper3_value = helper3("boo")
        text "helper3: #{helper3_value}, done"
      end
    end

    expect(render(wc)).to eq("helper3: this is boo helper3, done")
  end

  it "should allow aliasing helper method names" do
    wc = widget_class do
      helper :h2a, :call => :helper2
      helper :h2b, :call => :helper2, :transform => :output_return_value

      def content
        h2b("yo")
        text ", h2a: #{h2a('xx')}, done"
      end
    end

    expect(render(wc)).to eq("this is yo helper2, h2a: this is xx helper2, done")
  end

  it "should allow declaring helpers with :transform = nil, false, or none" do
    wc = widget_class do
      automatic_helper_access false
      helper :helper1, :transform => nil
      helper :helper2, :transform => false
      helper :helper3, :transform => :none

      def content
        text "helper1: #{helper1}, helper2: #{helper2('yo')}, helper3: "
        helper3("hi")
      end
    end

    expect(render(wc)).to eq("helper1: this is helper1, helper2: this is yo helper2, helper3: this is hi helper3")
  end

  it "should validate the options passed to .helper" do
    expect { widget_class { helper :foo, :transform => :boo } }.to raise_error(ArgumentError)
    expect { widget_class { helper :foo, :foo => :bar } }.to raise_error(ArgumentError)
  end
end
