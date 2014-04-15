describe "Rails complex helper support", :type => :rails do
  uses_rails_with_template :complex_helpers_system_spec

  it "should render form_for correctly" do
    expect_match("form_for_test",
      %r{OUTSIDE_BEFORE\s*<form.*action=\"/complex_helpers_system_spec/form_for_test\".*
        INSIDE_BEFORE\s*
        FIRST:\s*<input.*person_first_name.*/>\s*
        LAST:\s*<input.*person_last_name.*/>\s*
        INSIDE_AFTER\s*
        </form>\s*
        OUTSIDE_AFTER}mix)
  end
end
