describe "Rails class-loading support", :type => :rails do
  uses_rails_with_template :class_loading_system_spec

  it "should not load classes under app/views without the Views:: prefix" do
    expect_exception('the_class_should_not_load', 'NameError',
      /uninitialized constant ClassLoadingSystemSpec::ClassShouldNotLoad/i)
  end

  it "should allow me to define classes under Views:: outside of app/views, like in lib/views" do
    expect_match('lib_views', /hello: i am lib\/views/)
  end

  it "should allow me to define classes under Views:: outside of app/views, but in some other autoloaded place, like app/models" do
    expect_match('app_models', /hello: i am app\/models/)
  end

  it "should not create anonymous modules without the Views:: namespace for directories under app/views/" do
    expect_exception('some_namespace', 'NameError', /uninitialized constant SomeNamespace/)
    expect_exception('some_other_namespace', 'NameError', /uninitialized constant SomeNamespace/)
    expect_match('views_some_namespace', /Views::SomeNamespace/, :no_layout => true)
    expect_match('views_some_other_namespace', /Views::SomeNamespace::SomeOtherNamespace/, :no_layout => true)
  end

  it "should autoload widgets under app/views/"
  it "should allow me to define widgets outside of app/views/, just in case I feel like it"
  it "should let me define a widget in a file starting with an underscore, yet use it like any other widget"
  it "should let me render a widget defined outside of app/views/ if I use render :widget"
end
