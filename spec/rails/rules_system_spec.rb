describe "Rails rules support", :type => :rails do
  uses_rails_with_template :rules_system_spec

  it "should be able to enforce tag-nesting rules in Rails" do
    expect_exception('invalidly_nested_tag', Fortitude::Errors::InvalidElementNesting, /div/)
  end

  it "should still enforce tag-nesting rules inside a partial" do
    expect_exception('invalidly_nested_tag_in_partial', Fortitude::Errors::InvalidElementNesting, /div/)
  end

  it "should not enforce tag-nesting rules at the start of a partial rendered from ERb" do
    expect_match("invalid_start_tag_in_partial", /we got there\!/)
  end

  it "should not enforce tag-nesting rules from layout to view, even if both are in Fortitude" do
    expect_match('invalid_start_tag_in_view', /we got there\!/)
  end

  it "should not enforce tag-nesting rules across an intervening partial" do
    expect_match('intervening_partial', /we got there\!/)
  end
end
