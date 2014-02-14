describe "Fortitude needs", :type => :system do
  describe "inheritance" do
    it "should require needs from all superclasses" do
      grandparent = widget_class { needs :foo }
      parent = widget_class(:superclass => grandparent) { needs :bar }
      child = widget_class(:superclass => parent) do
        needs :baz
        def content
          text "foo: #{foo}, bar: #{bar}, baz: #{baz}"
        end
      end

      expect { child.new }.to raise_error(Fortitude::Errors::MissingNeed)
      expect { child.new(:foo => 'f') }.to raise_error(Fortitude::Errors::MissingNeed)
      expect { child.new(:foo => 'f', :bar => 'b') }.to raise_error(Fortitude::Errors::MissingNeed)
      expect(render(child.new(:foo => 'f', :bar => 'b', :baz => 'z'))).to eq("foo: f, bar: b, baz: z")
    end
  end

  describe "defaults" do
    it "should allow supplying defaults, and allow overriding them"
    it "should inherit defaults properly"
    it "should allow overriding a default with a requirement"
    it "should allow overriding a requirement with a default"
  end

  describe "extra assigns" do
    it "should, by default, ignore assigns it doesn't need"
    it "should fail if passed assigns it doesn't need, if asked to"
    it "should use extra assigns it doesn't need, if asked to"
  end
end
