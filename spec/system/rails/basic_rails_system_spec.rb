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

  it "should allow me to define classes under Views:: outside of app/views, like in lib/views"
  it "should allow me to define classes under Views:: outside of app/views, but in some other autoloaded place, like app/models"
  it "should not create anonymous modules without the Views:: namespace for directories under app/views/"
end
