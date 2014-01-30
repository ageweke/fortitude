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
