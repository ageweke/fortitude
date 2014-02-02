describe "Rails data-passing support", :type => :rails do
  uses_rails_with_template :data_passing_system_spec

  it "should allow passing data to the widget through controller variables" do
    expect_match("passing_data_widget", /foo is: the_foo/, /bar is: and_bar/)
  end

  it "should allow passing data to the widget through :locals => { ... }" do
    expect_match("passing_locals_widget", /foo is: local_foo/, /bar is: local_bar/)
  end

  it "should merge locals and controller variables, with locals winning" do
    expect_match("passing_locals_and_controller_variables_widget", /foo is: controller_foo/, /bar is: local_bar/, /baz is: local_baz/)
  end

  it "should give you a reasonable error if you omit a variable" do
    expect_exception('omitted_variable', 'Fortitude::Errors::MissingNeed', /bar/)
  end

  it "should not propagate un-needed variables" do
    expect_match("extra_variables", /foo method call: the_foo/, /foo instance var: nil/,
      /bar method call: NoMethodError/, /bar instance var: nil/,
      /baz method call: NoMethodError/, /baz instance var: nil/)
  end

  it "should not propagate a controller variable through a view to a child widget without being explicitly passed" do
    expect_exception('parent_to_child_passing', 'Fortitude::Errors::MissingNeed', /foo/)
  end
end
