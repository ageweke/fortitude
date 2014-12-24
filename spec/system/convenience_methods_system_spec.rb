describe "Fortitude convenience methods", :type => :system do
  describe "#all_fortitude_superclasses" do
    it "should return an empty array for ::Fortitude::Widget" do
      expect(::Fortitude::Widget.all_fortitude_superclasses).to eq([ ])
    end

    it "should return just ::Fortitude::Widget for a direct subclass" do
      class ConvenienceSpecAllSuperclassesDirectSubclass < ::Fortitude::Widget; end
      expect(ConvenienceSpecAllSuperclassesDirectSubclass.all_fortitude_superclasses).to eq([ ::Fortitude::Widget ])
    end

    it "should return a whole class hierarchy if appropriate" do
      class ConvenienceSpecAllSuperclassesGrandparent < ::Fortitude::Widget; end
      class ConvenienceSpecAllSuperclassesParent < ConvenienceSpecAllSuperclassesGrandparent; end
      class ConvenienceSpecAllSuperclassesChild < ConvenienceSpecAllSuperclassesParent; end
      expect(ConvenienceSpecAllSuperclassesChild.all_fortitude_superclasses).to eq([
        ConvenienceSpecAllSuperclassesParent,
        ConvenienceSpecAllSuperclassesGrandparent,
        ::Fortitude::Widget
      ])
    end
  end

  describe "#javascript" do
    it "should output JavaScript inside the proper tag, by default" do
      expect(render(widget_class_with_content { javascript "hi, there" })).to eq(
        %{<script>hi, there</script>})
    end

    it "should include newlines if we're formatting output, but not indent it" do
      wc = widget_class do
        format_output true

        def content
          div do
            text "hi"
            javascript "hi, there"
            text "bye"
          end
        end
      end

      expect(render(wc)).to eq(%{<div>
  hi
<script>
hi, there
</script>
  bye
</div>})
    end
  end

  describe "#content_and_attributes_from_tag_arguments" do
    let(:test_widget_instance) { widget_class.new }

    def caafta(*args)
      test_widget_instance.content_and_attributes_from_tag_arguments(*args)
    end

    it "should return nil and empty-hash for passing nothing" do
      expect(caafta()).to eq([ nil, { } ])
    end

    it "should return text if passed just text" do
      expect(caafta("foo")).to eq([ "foo", { } ])
    end

    it "should return attributes if passed just that" do
      expect(caafta(:class => :bar)).to eq([ nil, { :class => :bar }])
    end

    it "should return text and attributes if passed that" do
      expect(caafta("foo", :class => :bar)).to eq([ "foo", { :class => :bar }])
    end
  end

  describe "#add_css_classes" do
    let(:widget_class_with_p_added_base) {
      widget_class do
        def classes_to_add
          [ :foo, :bar ]
        end

        def call_add_css_classes(*args)
          add_css_classes(classes_to_add, *args)
        end

        def p_added(*args, &block)
          p(*call_add_css_classes(*args), &block)
        end
      end
    }

    def widget_class_with_p_added(&block)
      widget_class(:superclass => widget_class_with_p_added_base, &block)
    end

    def widget_class_with_p_added_content(&block)
      widget_class_with_content(:superclass => widget_class_with_p_added_base, &block)
    end

    it "should correctly add classes if passed nothing at all" do
      expect(render(widget_class_with_p_added_content { p_added })).to eq(%{<p class="foo bar"></p>})
    end

    it "should correctly add classes if passed just text" do
      expect(render(widget_class_with_p_added_content { p_added "hello" })).to eq(%{<p class="foo bar">hello</p>})
    end

    it "should correctly add classes if passed just other attributes" do
      output = render(widget_class_with_p_added_content { p_added :id => :whatever })
      expect(output).to match(%r{<p [^>]*></p>})
      expect(output).to match(%r{id="whatever"})
      expect(output).to match(%r{class="foo bar"})
    end

    it "should correctly add classes if passed text, then attributes" do
      output = render(widget_class_with_p_added_content { p_added "hello", :id => :whatever })
      expect(output).to match(%r{<p [^>]*>hello</p>})
      expect(output).to match(%r{id="whatever"})
      expect(output).to match(%r{class="foo bar"})
    end

    it "should correctly add classes if passed nil, then attributes" do
      output = render(widget_class_with_p_added_content { p_added nil, :id => :whatever })
      expect(output).to match(%r{<p [^>]*></p>})
      expect(output).to match(%r{id="whatever"})
      expect(output).to match(%r{class="foo bar"})
    end

    it "should correctly add classes if passed text, then explicitly-nil attributes" do
      output = render(widget_class_with_p_added_content { p_added "hello", nil })
      expect(output).to match(%r{<p class="foo bar">hello</p>})
    end

    it "should correctly add classes if passed nil and nil" do
      expect(render(widget_class_with_p_added_content { p_added nil, nil })).to eq(%{<p class="foo bar"></p>})
    end

    it "should correctly add just a single class" do
      wc = widget_class_with_p_added do
        def classes_to_add
          :foo
        end

        def content
          p_added "hello"
        end
      end
      expect(render(wc)).to eq(%{<p class="foo">hello</p>})
    end

    def render_and_extract_classes(class_or_widget)
      output = render(class_or_widget)

      if output =~ %r{^<p class="(.*)"></p>}
        $1.split(" ")
      else
        raise "Unexpected content: #{output.inspect}"
      end
    end

    def expect_classes_transform(original_hash, expected_classes)
      expect(render_and_extract_classes(widget_class_with_p_added_content { p_added(original_hash) }).sort).to eq(
        expected_classes.sort)
    end

    it "should correctly add classes if the base has classes specified with a symbol" do
      expect_classes_transform({ :class => 'orig' }, %w{orig foo bar})
    end

    it "should correctly add classes if the base has classes specified with a string" do
      expect_classes_transform({ 'class' => 'orig' }, %w{orig foo bar})
    end

    it "should correctly add classes if the base has multiple classes" do
      expect_classes_transform({ :class => [ 'orig1', 'orig2', 'orig3' ] }, %w{orig1 orig2 orig3 foo bar})
    end

    it "should correctly add classes if the base has just one class" do
      expect_classes_transform({ :class => 'orig' }, %w{orig foo bar})
    end

    it "should correctly add classes if the base has explicit nil for :class" do
      expect_classes_transform({ 'class' => nil }, %w{foo bar})
    end

    it "should correctly add classes if the base has explicit empty-string for :class" do
      expect_classes_transform({ 'class' => '' }, %w{foo bar})
    end

    it "should correctly add classes if the base has explicit false for :class" do
      expect_classes_transform({ :class => false }, %w{foo bar})
    end

    it "should correctly add classes if the base has an array for :class" do
      expect_classes_transform({ :class => [ 'orig1', 'orig2', 'orig3' ] }, %w{orig1 orig2 orig3 foo bar})
    end

    it "should correctly add classes if the base has a whitespace-separated array of classes for :class" do
      expect_classes_transform({ 'class' => 'orig1 orig2 orig3' }, %w{foo bar orig1 orig2 orig3})
    end

    it "should allow being called as #add_css_class" do
      add_css_class_class = widget_class do
        def p_added(*args, &block)
          p(*add_css_class('foo', *args), &block)
        end

        def content
          p_added "hello"
        end
      end

      expect(render(add_css_class_class)).to eq('<p class="foo">hello</p>')
    end
  end
end
