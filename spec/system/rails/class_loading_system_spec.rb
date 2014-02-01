describe "Rails class-loading support", :type => :rails do
  uses_rails_with_template :class_loading_system_spec

  describe "error cases" do
    it "should not allow you to put Foo::Bar in app/views/foo/bar.rb and make it work" do
      expect_exception('the_class_should_not_load', 'NameError',
        /uninitialized constant ClassLoadingSystemSpec::ClassShouldNotLoad/i)
    end
  end

  it "should allow me to define classes under Views:: outside of app/views, like in lib/views"
  it "should allow me to define classes under Views:: outside of app/views, but in some other autoloaded place, like app/models"
  it "should not create anonymous modules without the Views:: namespace for directories under app/views/"
  it "should allow me to define widgets outside of app/views/, just in case I feel like it"
  it "should let me define a widget in a file starting with an underscore, yet use it like any other widget"
end
