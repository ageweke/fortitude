describe "Fortitude tag return values", :type => :system do
  context "should blow up when calling a method on" do
    def expect_nrv(name, &block)
      e = capture_exception(Fortitude::Errors::NoReturnValueFromTag) { render(widget_class_with_content(&block)) }
      expect(e).to be
      expect(e.method_name).to eq(name)
    end

    it "a simple tag" do
      expect_nrv(:foo) { p.foo }
    end

    it "a tag with attributes" do
      expect_nrv(:foo) { p(:foo => :bar).foo }
    end

    it "a tag with direct content" do
      expect_nrv(:foo) { p("whatever").foo }
    end

    it "a tag with a block" do
      expect_nrv(:foo) { p { text "whatever" }.foo }
    end

    it "a tag with a block and direct content" do
      expect_nrv(:foo) { p("foo") { text "whatever" }.foo }
    end

    it "a tag with direct content and attributes" do
      expect_nrv(:foo) { p("foo", :foo => :bar).foo }
    end

    it "a tag with a block and attributes" do
      expect_nrv(:foo) { p(:foo => :bar) { text "whatever" }.foo }
    end

    it "a tag with a block, direct content, and attributes" do
      expect_nrv(:foo) { p("foo", :foo => :bar) { text "whatever" }.foo }
    end
  end

  context "should not blow up when calling" do
    it "#is_a?" do
      wc = widget_class_with_content { text("value: #{p.is_a?(String).inspect}") }
      expect(render(wc)).to eq("<p></p>value: false")
    end
  end
end
