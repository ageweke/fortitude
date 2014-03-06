describe "Rails RenderingContext support", :type => :rails do
  uses_rails_with_template :rendering_context_system_spec

  it "should use the context returned by fortitude_rendering_context in the view" do
    expect_match("uses_specified_context_in_view", /context is: SimpleRc, value 12345/)
  end

  it "should still use that context even for partials invoked by ERb" do
    expect_match("uses_specified_context_in_partials", /before partial.*context is: SimpleRc, value 23456.*after partial/mi)
  end

  it "should use that context for partials through multiple layers of nesting" do
    text = get_success("uses_specified_context_through_nesting")
    if text =~ /view rc: SimpleRc, 34567, (\d+).*partial.*inner partial rc: SimpleRc, 34567, (\d+)/mi
      first_value, second_value = Integer($1), Integer($2)
      expect(first_value).to eq(second_value)
    else
      raise "Text did not match: #{text.inspect}"
    end
  end

  it "should call start_widget! and end_widget! properly on widgets in Rails"
  it "should call start_widget! and end_widget! through ERb partials, passing them as hashes"
end
