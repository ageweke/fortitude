describe "basic Rails support", :type => :rails do
  uses_rails_with_template :basic_rails_system_spec

  it "should be able to render a trivial widget" do
    expect_match("trivial_widget", /layout_default/, /hello, world/)
  end

  describe "error cases" do
    it "should not allow you to put Foo::Bar in app/views/foo/bar.rb and make it work" do
      expect_exception('the_class_should_not_load', 'NameError',
        /uninitialized constant BasicRailsSystemSpec::ClassShouldNotLoad/i)
    end
  end

  describe "development mode" do
    it "should automatically reload widgets if they change on disk"
  end
end
