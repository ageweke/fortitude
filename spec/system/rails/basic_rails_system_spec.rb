describe "Fortitude Rails support", :type => :rails do
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

  describe "data passing" do
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
  end

  describe "rendering types" do
    it "should let you specify a widget with 'render :action =>'" do
      expect_match("render_with_colon_action", /hello, world/)
    end

    it "should let you specify a widget with 'render :template =>'" do
      expect_match("render_with_colon_template", /hello, world/)
    end

    it "should let you specify a widget with 'render :widget =>'"
    it "should let you render a widget with 'render \"foo\"'"
    it "should let you render a widget with 'render :file =>'"
    it "should let you render a widget inline with 'render :inline =>'"
  end

  describe "rendering in a widget" do
    it "should let you render :json in a widget"
    it "should let you render :xml in a widget"
    it "should let you render :js in a widget"
  end

  describe "render options" do
    it "should let you set the content-type"
    it "should let you set the location"
    it "should let you set the status"
  end

  describe "rendering partial invocation" do
    it "should render a collection correctly if so invoked"
    it "should support :as for rendering"
    it "should support :object for rendering"
    it "should support ERb partial layouts"
    it "should support using a widget as an ERb partial layout"
  end

  describe "localization support" do
    it "should allow you to provide localized widgets"
  end

  describe "development mode" do
    it "should automatically reload widgets if they change on disk"
  end

  describe "ERb template integration" do
    it "should let you call a widget from an ERb file with render :partial" do
      expect_match("erb_to_widget_with_render_partial", /erb to widget with render partial widget/,
        /erb_start/, /erb_end/, /erb_start.*erb to widget with render partial widget.*erb_end/m)
    end

    it "should prefer ERb partials to Fortitude partials" do
      expect_match("prefers_erb_partial", /erb partial/,
        /erb_start.*erb partial.*erb_end/m)
    end

    it "should allow you to define a Fortitude partial in a file with an underscore" do
      expect_match('fortitude_partial_with_underscore', /fortitude partial with underscore partial/,
        /erb_start.*fortitude partial with underscore partial.*erb_end/m)
    end

    it "should let you call an ERb partial from a widget with render :partial"
  end

  describe "layout integration" do
    it "should let you use a widget in an ERb layout, and render in the right order"
    it "should let you use a widget as a layout with an ERb view, and render in the right order"
    it "should let you use a widget as a layour with a widget view, and render in the right order"
    it "should let you select the layout"
  end

  describe "helper integration" do
    it "should support the built-in Rails helpers by default"
    it "should support both rendered and unrendered helpers properly"
    it "should support custom-defined helpers"
  end

  describe "capture integration" do
    it "should successfully capture a widget partial with capture { } in an ERb view"
    it "should successfully capture an ERb partial with capture { } in a widget"
    it "should be able to provide content in a widget with content_for"
    it "should be able to provide content in a widget with provide"
    it "should be able to retrieve stored content in a widget with content_for :name"
    it "should be able to retrieve stored content in a widget with yield :name"
  end

  describe "translation integration" do
    it "should let you translate strings with I18n.t"
    it "should let you translate strings with just t"
    it "should let you translate strings with Fortitude translation support"
    it "should let you provide localized widgets"
  end
end
