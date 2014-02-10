describe "Fortitude helpers with config.action_controller.include_all_helpers = false", :type => :rails do
  uses_rails_with_template :helpers_include_all_off_system_spec

  it "should not include all helpers" do
    expect_match("include_all_off", /excitedly: awesome!!!; uncertainly: NoMethodError/mi)
  end
end
