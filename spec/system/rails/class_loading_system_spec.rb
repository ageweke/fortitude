describe "Rails class-loading support", :type => :rails do
  uses_rails_with_template :class_loading_system_spec

  it "should not load classes under app/views without the Views:: prefix" do
    expect_exception('the_class_should_not_load', 'NameError',
      /uninitialized constant ClassLoadingSystemSpec::ClassShouldNotLoad/i)
  end

  it "should allow me to define classes under Views:: outside of app/views, like in lib/views" do
    expect_match('lib_views', /hello: i am lib\/views/)
  end

  it "should allow me to define classes under Views:: outside of app/views, but in some other autoloaded place, like app/models"
  it "should not create anonymous modules without the Views:: namespace for directories under app/views/"
  it "should allow me to define widgets outside of app/views/, just in case I feel like it"
  it "should let me define a widget in a file starting with an underscore, yet use it like any other widget"
  it "should let me render a widget defined outside of app/views/ if I use render :widget"
end
