describe "Rails rendering support", :type => :rails do
  uses_rails_with_template :rendering_system_spec

  describe "rendering from a controller" do
    it "should let you specify a widget with 'render :action =>'" do
      expect_match("render_with_colon_action", /hello, world/)
    end

    it "should let you specify a widget with 'render :template =>'" do
      expect_match("render_with_colon_template", /hello, world/)
    end

    it "should let you specify a widget with 'render :widget =>', which should use a layout by default" do
      data = expect_match("render_widget", /hello from a widget named Fred/)
      expect(data).to match(/rails_spec_application/)
    end

    it "should let you omit the layout with 'render :widget =>', if you ask for it" do
      data = expect_match("render_widget_without_layout", /hello from a widget named Fred/, :no_layout => true)
      expect(data).not_to match(/rails_spec_application/)
    end

    it "should let you render a widget with 'render \"foo\"'" do
      expect_match("render_widget_via_file_path", /hello from a widget named Fred/)
    end

    it "should let you render a widget with 'render :file =>'" do
      expect_match("render_widget_via_colon_file", /hello from a widget named Fred/)
    end

    it "should let you render a widget inline with 'render :inline =>'" do
      expect_match("render_widget_via_inline", /this is an inline widget named Fred/)
    end

    it "should let you render a widget inline, and use all instance and local variables"
  end

  describe "rendering in a widget" do
    it "should let you render a partial in a widget" do
      expect_match("render_partial_from_widget", /this is the widget.*this is the_partial.*this is the widget again/mi)
    end

    it "should let you render :text in a widget" do
      expect_match("render_text_from_widget", /this is the widget.*this is render_text.*this is the widget again/mi)
    end

    it "should let you render :template in a widget" do
      expect_match("render_template_from_widget", /this is the widget.*widget_with_name: Fred.*this is the widget again/mi)
    end

    it "should let you render :inline in a widget" do
      expect_match("render_inline_from_widget", /this is the widget.*widget_with_name: Fred.*this is the widget again/mi)
    end

    it "should let you render :file in a widget" do
      expect_match("render_file_from_widget", /this is the widget.*widget_with_name: Fred.*this is the widget again/mi)
    end
  end

  describe "render options" do
    it "should let you set the content-type" do
      data = get_response("render_with_content_type")
      expect(data.body.strip).to match(/hello, world/)
      content_type = data.header['content-type']
      expect(content_type).to match(%r{^boo/yeah(;.*)?$})
    end

    it "should let you set the location" do
      data = get_response("render_with_location")
      expect(data.body.strip).to match(/hello, world/)
      location = data.header['location']
      expect(location).to eq("http://somewhere/over/the/rainbow")
    end

    it "should let you set the status" do
      data = get_response("render_with_status", :ignore_status_code => true)
      expect(data.code.to_s).to eq("768")
    end
  end

  describe "rendering partial invocation" do
    it "should render a collection correctly if so invoked" do
      expect_match("render_collection", /collection is:.*word: apple.*word: pie.*word: is.*word: nice.*and that's all!/mi)
    end

    it "should support :as for rendering" do
      expect_match("render_collection_as", /collection is:.*widget_with_name: bonita.*widget_with_name: applebaum.*widget_with_name: the.*widget_with_name: dude.*and that's all!/mi)
    end

    it "should support :object for rendering" do
      expect_match("render_object", /partial is:.*word: donkey.*and that's all!/mi)
    end

    it "should support ERb partial layouts"
    it "should support using a widget as an ERb partial layout"
  end

  describe "streaming support" do
    it "should let you stream a pure widget"
    it "should let you stream from a widget that's in an ERb view"
  end
end
