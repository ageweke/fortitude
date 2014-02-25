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
end
