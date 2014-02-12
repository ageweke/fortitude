describe "Rails data-passing support", :type => :rails do
  uses_rails_with_template :data_passing_system_spec

  it "should allow passing data to the widget through controller variables" do
    expect_match("passing_data_widget", /foo is: the_foo/, /bar is: and_bar/)
  end

  it "should not fail if the controller provides more data than it needs" do
    expect_match("extra_data_widget", /foo is: the_foo/, /bar is: and_bar/)
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

  it "should let a widget read a controller variable explicitly, as a Symbol or a String" do
    expect_match("explicit_controller_variable_read", /explicit foo as symbol: the_foo/)
    expect_match("explicit_controller_variable_read", /explicit foo as string: the_foo/)
  end

  it "should let a widget read a controller variable set by an earlier ERb view" do
    expect_match("erb_to_parallel_widget_handoff", /widget foo: foo_from_erb/)
  end

  it "should let a widget write a controller variable that a later ERb view can read" do
    expect_match("widget_to_parallel_erb_handoff", /erb foo: foo_from_widget/)
  end

  describe "backwards-compatible instance-variable mode" do
    it "should let a widget read a controller variable implicitly" do
      expect_match("implicit_variable_read", /inner widget foo: foo_from_controller/)
    end

    it "should let a widget write a controller variable implicitly" do
      expect_match("implicit_variable_write", /erb foo: foo_from_widget/)
    end

    it "should let a widget read a controller variable set by an earlier ERb view" do
      expect_match("implicit_erb_to_widget_handoff", /widget foo: foo_from_erb/)
    end

    it "should not enable access to local variables via @foo directly" do
      expect_match("implicit_shared_variable_access", /foo: nil/)
    end

    it "should inherit the setting for implicit_shared_variable_access properly" do
      expect_match("implicit_shared_variable_access_inheritance", /C1: foo is , bar is .*C2: foo is the_foo, bar is the_bar/mi)
    end

    it "should have the same set of copied variables for ERb and a widget" do
      widget_copied_variables = JSON.parse(get('widget_copied_variables'))['widget_copied_variables'].sort
      erb_copied_variables = JSON.parse(get('erb_copied_variables'))['erb_copied_variables'].sort

      common = widget_copied_variables & erb_copied_variables
      extra_widget = widget_copied_variables - erb_copied_variables
      missing_widget = erb_copied_variables - widget_copied_variables

      extra_widget = extra_widget.reject { |v| v =~ /^@_fortitude_/i }

      expect(extra_widget).to eq([ ])
      expect(missing_widget).to eq([ ])
    end
  end
end
