describe "Fortitude unrefined Rails helper support", :type => :rails do
  uses_rails_with_template :helpers_unrefined_system_spec

  it "should not output when refined-outputting helpers are called" do
    expect_match("helpers_that_output_when_refined", /STARTEND/)
  end
end
