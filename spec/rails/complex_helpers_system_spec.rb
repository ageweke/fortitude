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

  it "should render fields_for correctly" do
    expect_match("fields_for_test",
      %r{OUTSIDE_BEFORE\s*
        INSIDE_BEFORE\s*
        FIRST:\s*<input.*person_first_name.*/>\s*
        LAST:\s*<input.*person_last_name.*/>\s*
        INSIDE_AFTER\s*
        OUTSIDE_AFTER}mix)
  end

  it "should cache based on a name properly" do
    expect_match("cache_test?a=a1&b=b1",
      /before_cache\(a1,b1\).*inside_cache\(a1,b1\).*after_cache\(a1,b1\)/mi)
    expect_match("cache_test?a=a1&b=b2",
      /before_cache\(a1,b2\).*inside_cache\(a1,b1\).*after_cache\(a1,b2\)/mi)
    expect_match("cache_test?a=a2&b=b2",
      /before_cache\(a2,b2\).*inside_cache\(a2,b2\).*after_cache\(a2,b2\)/mi)
  end
end
