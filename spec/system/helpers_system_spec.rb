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

      def output_buffer
        @output_buffer_holder.output_buffer
      end
    end

    @helpers_object = @helpers_class.new
    @helpers_object.output_buffer_holder = @output_buffer_holder
  end

  def render(widget_or_class, options = { })
    @output_buffer.clear
    super(widget_or_class, { :rendering_context => rc(
      :helpers_object => @helpers_object, :output_buffer_holder => @output_buffer_holder) }.merge(options))
  end

  it "should, by default, allow automatic access to helpers" do
    expect(render(widget_class_with_content { text "helper1: #{helper1}" })).to eq("helper1: this is helper1")
    expect(render(widget_class_with_content { text "helper2: #{helper2("yo")}" })).to eq("helper2: this is yo helper2")
    expect(render(widget_class_with_content { helper3("ho") })).to eq("this is ho helper3")
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

  it "should allow aliasing helper method names"
  it "should validate the options passed to .helper"
end
