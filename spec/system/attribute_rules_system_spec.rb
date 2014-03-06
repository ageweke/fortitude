describe "Fortitude attribute rules enforcement", :type => :system do
  def widget_class_with_content(options = { }, &block)
    out = super(options, &block)
    out.class_eval { enforce_attribute_rules true }
    out
  end

  it "should not allow an attribute 'foo' on <p>" do
    expect { render(widget_class_with_content { p :foo => 'bar' })}.to raise_error(Fortitude::Errors::InvalidElementAttributes)
  end

  it "should allow an attribute 'class' on <p>" do
    expect(render(widget_class_with_content { p :class => 'bar' })).to eq("<p class=\"bar\"/>")
  end

  it "should allow you to disable attribute rules with a block"
  it "should allow you to disable enforcement with a block, even across widget boundaries"
  it "should allow you to re-enable enforcement with a block"
  it "should allow you to re-enable enforcement with a block, even across widget boundaries"
  it "should raise an error if you try to enable enforcement with a block in a widget that isn't enforcing in the first place"
  it "should not raise an error if you try to DISable enforcement with a block in a widget that isn't enforcing in the first place"

  it "should allow disabling attribute rules on a single element with an option" do
    expect(render(widget_class_with_content { p :foo => 'bar', :_fortitude_disable_attribute_rule_enforcement => true })).to eq("<p foo=\"bar\"/>")
  end
end
