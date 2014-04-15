describe "Fortitude tag rules enforcement", :type => :system do
  def widget_class(options = { }, &block)
    out = super(options, &block)
    out.class_eval { enforce_element_nesting_rules true } unless options[:no_enforcement]
    out
  end

  it "should not allow a <div> inside a <p>" do
    expect { render(widget_class_with_content { p { div } })}.to raise_error(Fortitude::Errors::InvalidElementNesting)
  end

  it "should quote HTML specifications at you when you screw up" do
    expect { render(widget_class_with_content { p { div } })}.to raise_error(Fortitude::Errors::InvalidElementNesting, /THE_SPEC_FOR_P/)
  end

  it "should allow a <b> inside a <p>" do
    expect(render(widget_class_with_content { p { b } })).to eq('<p><b/></p>')
  end

  it "should not allow text where it's, well, not allowed, when specified directly" do
    expect { render(widget_class_with_content { div "hi" }) }.to raise_error(Fortitude::Errors::InvalidElementNesting)
  end

  it "should not allow text where it's, well, not allowed, when specified directly and with a hash" do
    expect { render(widget_class_with_content { div "hi", :class => "something" }) }.to raise_error(Fortitude::Errors::InvalidElementNesting)
  end

  it "should not allow text where it's, well, not allowed, when specified indirectly" do
    expect { render(widget_class_with_content { div { text "hi" } }) }.to raise_error(Fortitude::Errors::InvalidElementNesting)
  end

  it "should always allow rawtext" do
    expect(render(widget_class_with_content { div { rawtext "yo" }})).to eq("<div>yo</div>")
  end

  it "should always allow html_safe text, when specified indirectly" do
    expect(render(widget_class_with_content { div { text "yo".html_safe } })).to eq("<div>yo</div>")
  end

  it "should always allow html_safe text, when specified directly" do
    expect(render(widget_class_with_content { div "yo".html_safe })).to eq("<div>yo</div>")
  end

  it "should not enforce rules inside a widget with the setting off, even if surrounding widgets have it on" do
    outer = widget_class do
      attr_accessor :inner
      def content
        p do
          widget inner
        end
      end
    end

    middle = widget_class(:no_enforcement => true) do
      attr_accessor :inner
      def content
        div do
          p do
            widget inner
          end
        end
      end
    end

    inner = widget_class_with_content do
      text "yo"
    end

    outer_instance = outer.new
    middle_instance = middle.new
    inner_instance = inner.new

    outer_instance.inner = middle_instance
    middle_instance.inner = inner_instance

    expect(render(outer_instance)).to eq("<p><div><p>yo</p></div></p>")
  end

  it "should still enforce rules from one widget to the next" do
    outer = widget_class do
      attr_accessor :inner
      def content
        p do
          widget inner
        end
      end
    end

    middle = widget_class do
      def content
        div do
          text "hi"
        end
      end
    end

    outer_instance = outer.new
    middle_instance = middle.new

    outer_instance.inner = middle_instance

    expect { render(outer_instance) }.to raise_error(Fortitude::Errors::InvalidElementNesting)
  end

  it "should allow you to disable enforcement with a block" do
    wc = widget_class_with_content do
      p do
        with_element_nesting_rules(false) do
          div do
            text "hi"
          end
        end
      end
    end

    expect(render(wc)).to eq("<p><div>hi</div></p>")
  end

  it "should allow you to disable enforcement with a block, even across widget boundaries" do
    outer = widget_class do
      attr_accessor :inner
      def content
        p do
          with_element_nesting_rules(false) do
            widget inner
          end
        end
      end
    end

    inner = widget_class_with_content { div { text "hi" } }

    outer_instance = outer.new
    inner_instance = inner.new
    outer_instance.inner = inner_instance

    expect(render(outer_instance)).to eq("<p><div>hi</div></p>")
  end

  it "should allow you to re-enable enforcement with a block" do
    wc = widget_class_with_content do
      with_element_nesting_rules(false) do
        p do
          with_element_nesting_rules(true) do
            div do
              text "hi"
            end
          end
        end
      end
    end

    expect { render(wc) }.to raise_error(Fortitude::Errors::InvalidElementNesting)
  end

  it "should let you re-enable enforcement with a block, even across widget boundaries" do
    outer = widget_class do
      attr_accessor :inner
      def content
        with_element_nesting_rules(false) do
          p do
            widget inner
          end
        end
      end
    end

    inner = widget_class_with_content { with_element_nesting_rules(true) { div { text "hi" } } }

    outer_instance = outer.new
    inner_instance = inner.new
    outer_instance.inner = inner_instance

    expect { render(outer_instance) }.to raise_error(Fortitude::Errors::InvalidElementNesting)
  end

  it "should raise an error if you try to enable enforcement with a block in a widget that isn't enforcing in the first place" do
    wc = widget_class_with_content(:no_enforcement => true) do
      with_element_nesting_rules(true) do
        text "hi"
      end
    end

    expect { render(wc) }.to raise_error(ArgumentError)
  end

  it "should not raise an error if you try to DISable enforcement with a block in a widget that isn't enforcing in the first place" do
    wc = widget_class_with_content(:no_enforcement => true) do
      with_element_nesting_rules(false) do
        text "hi"
      end
    end

    expect(render(wc)).to eq("hi")
  end
end
