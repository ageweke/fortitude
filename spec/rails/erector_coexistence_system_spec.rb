describe "Erector coexistence support", :type => :rails do
  uses_rails_with_template :erector_coexistence_system_spec, :additional_gemfile_lines => "gem 'erector'"

  it "should be able to render a Fortitude widget" do
    expect_match("fortitude_widget", /this is Fortitude: foo = bar/)
  end

  it "should be able to render an Erector widget" do
    expect_match("erector_widget_in_app_views", /<p\s+class\s*=\s*"some_class"\s*>this is Erector: foo = baz<\/p>/)
  end
end
