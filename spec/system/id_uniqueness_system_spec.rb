describe "Fortitude ID uniqueness", :type => :system do
  def widget_class(options = { }, &block)
    needs_uniqueness = true unless options.delete(:no_enforcement)
    out = super(options, &block)
    out.class_eval { enforce_id_uniqueness true } if needs_uniqueness
    out
  end

  it "should not enforce ID uniqueness by default" do
    wc = widget_class_with_content(:no_enforcement => true) do
      p :id => "foo"
      p :id => "foo"
    end

    expect(render(wc)).to eq("<p id=\"foo\"/><p id=\"foo\"/>")
  end

  it "should enforce ID uniqueness if asked to" do
    wc = widget_class_with_content do
      p :id => "foo"
      p :id => "foo"
    end

    instance = wc.new
    e = capture_exception(Fortitude::Errors::DuplicateId) { render(instance) }
    expect(e.widget).to be(instance)
    expect(e.id).to eq("foo")
    expect(e.already_used_widget).to be(instance)
    expect(e.already_used_tag_name).to eq(:p)
    expect(e.tag_name).to eq(:p)
  end

  it "should enforce ID uniqueness between Symbols and Strings properly" do
    wc = widget_class_with_content do
      p :id => :foo
      p :id => "foo"
    end

    instance = wc.new
    e = capture_exception(Fortitude::Errors::DuplicateId) { render(instance) }
    expect(e.widget).to be(instance)
    expect(e.id).to eq("foo")
    expect(e.already_used_widget).to be(instance)
    expect(e.already_used_tag_name).to eq(:p)
    expect(e.tag_name).to eq(:p)
  end

  it "should enforce ID uniqueness across different kinds of tags" do
    wc = widget_class_with_content do
      p :id => "foo"
      div :id => :foo
    end

    instance = wc.new
    e = capture_exception(Fortitude::Errors::DuplicateId) { render(instance) }
    expect(e.widget).to be(instance)
    expect(e.id).to eq("foo")
    expect(e.already_used_widget).to be(instance)
    expect(e.already_used_tag_name).to eq(:p)
    expect(e.tag_name).to eq(:div)
  end

  it "should enforce ID uniqueness across different widgets" do
    outer = widget_class do
      attr_accessor :inner
      def content
        p :id => 'foo'
        widget inner
      end
    end

    inner = widget_class_with_content do
      p :id => :foo
    end

    outer_instance = outer.new
    inner_instance = inner.new
    outer_instance.inner = inner_instance

    e = capture_exception(Fortitude::Errors::DuplicateId) { render(outer_instance) }
    expect(e.widget).to be(inner_instance)
    expect(e.id).to eq("foo")
    expect(e.already_used_widget).to be(outer_instance)
    expect(e.already_used_tag_name).to eq(:p)
    expect(e.tag_name).to eq(:p)
  end

  it "should not enforce uniqueness inside a widget with the setting off, even if surrounding widgets have it on"
  it "should allow you to disable enforcement with a block"
  it "should allow you to disable enforcement with a block, even across widget boundaries"
  it "should allow you to re-enable enforcement with a block"
  it "should let you re-enable enforcement with a block, even across widget boundaries"
  it "should raise an error if you try to enable enforcement with a block in a widget that isn't enforcing in the first place"
  it "should not raise an error if you try to DISable enforcement with a block in a widget that isn't enforcing in the first place"
end
