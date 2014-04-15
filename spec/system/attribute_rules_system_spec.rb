describe "Fortitude attribute rules enforcement", :type => :system do
  def widget_class(options = { }, &block)
    out = super(options, &block)
    out.class_eval { enforce_attribute_rules true } unless options.delete(:no_enforcement)
    out
  end

  it "should not allow an attribute 'foo' on <p>" do
    expect { render(widget_class_with_content { p :foo => 'bar' })}.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should allow an attribute 'class' on <p>" do
    expect(render(widget_class_with_content { p :class => 'bar' })).to eq("<p class=\"bar\"/>")
  end

  it "should allow arbitrary individual data-* attributes" do
    expect(render(widget_class_with_content { p :'data-foo' => 'bar', 'DATA-BAZ' => 'quux' })).to eq('<p data-foo="bar" DATA-BAZ="quux"/>')
  end

  it "should allow a data attribute, specified as a Hash" do
    expect(render(widget_class_with_content { p :data => { :foo => 'bar', 'baz' => 'quux' }})).to eq('<p data-foo="bar" data-baz="quux"/>')
  end

  it "should not allow a plain 'data' attribute" do
    expect { render(widget_class_with_content { p :data => 'foo' }) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should not allow a plain 'data-' attribute" do
    expect { render(widget_class_with_content { p :'data-' => 'foo' }) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  def class_with_custom_tag(additional_attributes, &block)
    out = widget_class
    out.class_eval do
      tag :mytag, { :valid_attributes => %w{foo bar} }.merge(additional_attributes)
    end
    out.class_eval(&block) if block
    out
  end

  it "should allow data and ARIA attributes by default" do
    klass = class_with_custom_tag({ }) do
      def content
        mytag :foo => 'bar', :data => { 'aaa' => 'bbb' }, :aria => { 'ccc' => 'ddd' }
      end
    end

    expect(render(klass)).to eq("<mytag foo=\"bar\" data-aaa=\"bbb\" aria-ccc=\"ddd\"/>")
  end

  it "should not allow data attributes if told not to" do
    klass = class_with_custom_tag(:allow_data_attributes => false) do
      def content
        mytag :foo => 'bar', :data => { :aaa => 'bbb' }
      end
    end
    expect { render(klass) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should not allow ARIA attributes if told not to" do
    klass = class_with_custom_tag(:allow_aria_attributes => false) do
      def content
        mytag :foo => 'bar', :aria => { :ccc => 'ddd' }
      end
    end
    expect { render(klass) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should not enforce rules inside a widget with the setting off, even if surrounding widgets have it on" do
    outer = widget_class do
      attr_accessor :inner
      def content
        widget inner
      end
    end

    middle = widget_class(:no_enforcement => true) do
      attr_accessor :inner
      def content
        p :foo => 'bar'
        widget inner
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

    expect(render(outer_instance)).to eq("<p foo=\"bar\"/>yo")
  end

  it "should allow you to disable attribute rules with a block" do
    wc = widget_class_with_content do
      begin
        p :foo => 'bar'
      rescue => e
        text e.class.name
      end

      with_attribute_rules(false) do
        begin
          p :foo => 'bar'
        rescue => e
          text e.class.name
        end
      end

      begin
        p :foo => 'bar'
      rescue => e
        text e.class.name
      end
    end

    expect(render(wc)).to eq("Fortitude::Errors::InvalidElementAttributes<p foo=\"bar\"/>Fortitude::Errors::InvalidElementAttributes")
  end

  it "should allow you to disable enforcement with a block, even across widget boundaries" do
    outer = widget_class do
      attr_accessor :inner
      def content
        with_attribute_rules(false) do
          widget inner
        end
      end
    end

    inner = widget_class_with_content do
      p :foo => 'bar'
    end

    inner_instance = inner.new
    outer_instance = outer.new
    outer_instance.inner = inner_instance

    expect { render(inner_instance) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
    expect(render(outer_instance)).to eq("<p foo=\"bar\"/>")
  end

  it "should allow you to re-enable enforcement with a block" do
    wc = widget_class_with_content do
      with_attribute_rules(false) do
        with_attribute_rules(true) do
          p :foo => 'bar'
        end
      end
    end

    expect { render(wc) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should allow you to re-enable enforcement with a block, even across widget boundaries" do
    outer = widget_class do
      attr_accessor :inner
      def content
        with_attribute_rules(false) do
          widget inner
        end
      end
    end

    middle = widget_class do
      attr_accessor :inner
      def content
        with_attribute_rules(true) do
          widget inner
        end
      end
    end

    inner = widget_class_with_content do
      p :foo => 'bar'
    end

    inner_instance = inner.new
    middle_instance = middle.new
    middle_instance.inner = inner_instance
    outer_instance = outer.new
    outer_instance.inner = middle_instance

    expect { render(inner_instance) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
    expect { render(outer_instance) }.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should raise an error if you try to enable enforcement with a block in a widget that isn't enforcing in the first place" do
    wc = widget_class_with_content(:no_enforcement => true) do
      with_attribute_rules(true) do
        p :foo => 'bar'
      end
    end

    expect { render(wc) }.to raise_error(ArgumentError)
  end

  it "should not raise an error if you try to DISable enforcement with a block in a widget that isn't enforcing in the first place" do
    wc = widget_class_with_content(:no_enforcement => true) do
      p :bar => 'baz'
      with_attribute_rules(false) do
        p :foo => 'bar'
      end
    end

    expect(render(wc)).to eq("<p bar=\"baz\"/><p foo=\"bar\"/>")
  end

  it "should allow disabling attribute rules on a single element with an option" do
    expect(render(widget_class_with_content { p :foo => 'bar', :_fortitude_skip_attribute_rule_enforcement => true })).to eq("<p foo=\"bar\"/>")
  end
end
