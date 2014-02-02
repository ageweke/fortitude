describe "Rails rendering support", :type => :rails do
  uses_rails_with_template :rendering_system_spec

  describe "rendering from a controller" do
    it "should let you specify a widget with 'render :action =>'" do
      expect_match("render_with_colon_action", /hello, world/)
    end

    it "should let you specify a widget with 'render :template =>'" do
      expect_match("render_with_colon_template", /hello, world/)
    end

    it "should let you specify a widget with 'render :widget =>'" do
      # I *think* we want to patch in at ActionView::TemplateRenderer#determine_template(options)
      expect_match("render_widget", /hello from a widget named Fred!/)
    end

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
end
