describe "Rails RenderingContext support", :type => :rails do
  uses_rails_with_template :rendering_context_system_spec

  it "should use the context returned by fortitude_rendering_context in the view" do
    expect_match("uses_specified_context_in_view", /context is: SimpleRc, value 12345/)
  end
end
