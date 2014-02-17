describe "Fortitude shared_variable access", :type => :system do
  describe "explicit shared-variable access" do
    it "should allow reading a shared variable" do
      ivars[:foo] = "the_foo"
      expect(render(widget_class_with_content { text "foo: #{shared_variables[:foo]}" })).to eq("foo: the_foo")
    end

    it "should allow writing a shared variable" do
      expect(render(widget_class_with_content { shared_variables[:foo] = "blah"; text "foo: #{shared_variables[:foo]}" })).to eq("foo: blah")
      expect(ivars[:foo]).to eq("blah")
    end

    it "shouldn't care if you use a symbol or a string" do
      ivars[:foo] = "the_foo"
      expect(render(widget_class_with_content { text "foo: #{shared_variables[:foo]}, #{shared_variables['foo']}"; shared_variables['foo'] = "blah" })).to eq("foo: the_foo, the_foo")
      expect(ivars[:foo]).to eq("blah")
    end

    it "should stringify whatever key you give it" do
      obj = Object.new
      class << obj
        def to_s
          "foo"
        end
      end

      ivars[:foo] = "the_foo"
      expect(render(widget_class_with_content { text "foo: #{shared_variables[obj]}" })).to eq("foo: the_foo")
    end
  end

  describe "implicit shared-variable access" do
    it "should not function unless explicitly turned on" do
      ivars[:foo] = "the_foo"
      expect(render(widget_class_with_content { text "foo: #{@foo}"; @bar = "the_bar" })).to eq("foo: ")
      expect(ivars[:bar]).to eq(nil)
    end

    it "should allow reading shared variables implicitly" do
      ivars[:foo] = "the_foo"
      wc = widget_class do
        implicit_shared_variable_access true
        def content
          text "foo: #{@foo}"
        end
      end
      expect(render(wc.new)).to eq("foo: the_foo")
    end

    it "should allow writing shared variables implicitly" do
      ivars[:foo] = "the_foo"
      wc = widget_class do
        implicit_shared_variable_access true
        def content
          text "foo: #{@foo}"
          @foo = "bar"
        end
      end
      expect(render(wc.new)).to eq("foo: the_foo")
      expect(ivars[:foo]).to eq("bar")
    end

    it "should allow writing shared variables implicitly, even if they weren't defined going in" do
      wc = widget_class do
        implicit_shared_variable_access true
        def content
          text "foo: #{@foo}"
          @foo = "bar"
        end
      end
      expect(render(wc.new)).to eq("foo: ")
      expect(ivars[:foo]).to eq("bar")
    end

    describe "interactions with use_instance_variables_for_assigns and extra_assigns" do
      it "should have needs declarations pre-empt shared variables" do
        wc = widget_class do
          implicit_shared_variable_access true
        end
      end

      it "should have extra assigns pre-empt shared variables"
    end
  end
end
