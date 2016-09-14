describe "Rails class-loading support", :type => :rails do
  uses_rails_with_template :class_loading_system_spec

  it "should allow me to define classes under Views:: outside of app/views, like in lib/views" do
    expect_match('lib_views', /hello: i am lib\/views/)
  end

  it "should allow me to define classes under Views:: outside of app/views, but in some other autoloaded place, like app/models" do
    expect_match('app_models', /hello: i am app\/models/)
  end

  it "should not create anonymous modules without the Views:: namespace for directories under app/views/" do
    expect_exception('some_namespace', 'NameError', /uninitialized constant SomeNamespace/)
    expect_exception('some_other_namespace', 'NameError', /uninitialized constant SomeNamespace/)
  end

  it "should autoload widgets under app/views/" do
    expect_match('autoload_widget', /autoload_widget is here!/, :no_layout => true)
  end

  it "should autoload one widget from another" do
    expect_match('autoload_one_widget_from_another', /about to run the sub widget.*this is the sub widget.*ran the sub widget/)
  end

  it "should allow use of a widget defined in lib/ from a view widget" do
    expect_match('use_lib_widget_from_view_widget', /about to run the lib widget.*this is the lib widget.*ran the lib widget/)
  end

  it "should allow use of a widget defined on another autoload path from a view widget" do
    expect_match('use_models_widget_from_view_widget', /about to run the models widget.*this is the models widget.*ran the models widget/)
  end

  it "should not allow me to define widgets outside of app/views/" do
    if Gem::Version.new(rails_server_default_version) >= Gem::Version.new('5.0.0')
      expect_status('widget_defined_outside_app_views', 204)
    else
      expect_exception(
        'widget_defined_outside_app_views',
        'ActionView::MissingTemplate',
        /class_loading_system_spec\/widget_defined_outside_app_views/
      )
    end
  end

  it "should not let me define a widget in a file starting with an underscore, and use it for a view" do
    if Gem::Version.new(rails_server_default_version) >= Gem::Version.new('5.0.0')
      expect_status('widget_defined_outside_app_views', 204)
    else
      expect_exception(
        'underscore_view',
        'ActionView::MissingTemplate',
        /class_loading_system_spec\/underscore_view/
      )
    end
  end

  it "should prefer widgets defined in a file without an underscore to those with" do
    expect_match('foo', /foo WITHOUT underscore/)
  end

  it "should prefer widgets ending in .html.rb to those just ending in .rb" do
    expect_match('bar', /bar WITH html/)
  end

  it "should let me define a widget in a file starting with an underscore, and autoload it" do
    expect_match('underscore_widget_surrounding', /surrounding_widget before.*this is underscore_widget.*surrounding_widget after/)
  end

  it "should not let me 'require' files in app/views without a views/ prefix" do
    expect_exception('require_loaded_underscore_widget_without_views', 'LoadError', /(cannot load such file|no such file to load)/)
  end

  it "should not let me 'require' files in app/views with a views/ prefix" do
    expect_exception('require_loaded_underscore_widget_with_views', 'LoadError', /(cannot load such file|no such file to load)/)
  end

  it "should let me render a widget defined outside of app/views/ if I use render :widget" do
    expect_match('render_widget_outside_app_views', /arbitrary_name_some_widget/)
  end

  it "should not load view classes with any module nesting applied" do
    expect_match('show_module_nesting', /module_nesting: \[\]/)
  end
end
