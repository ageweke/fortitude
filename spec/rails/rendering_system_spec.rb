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

    it "should let you render a widget inline, and use all instance and local variables, with locals overriding instance variables" do
      expect_match("render_widget_via_inline_with_var_access", /this is an inline widget named Fred, and it is 27 years old, and friends with Mary/)
    end
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

    it "should support ERb partial layouts" do
      expect_match("render_partial_with_layout", /this is the partial:.*partial_layout before.*partial_with_layout.*partial_layout after.*done!/mi)
    end

    it "should support using a widget as an ERb partial layout" do
      expect_match("render_partial_with_widget_layout", /this is the partial:.*widget_partial_layout before.*partial_with_layout.*widget_partial_layout after.*done!/mi)
    end
  end

  describe "HTML escaping" do
    it "should only escape strings that aren't raw() or html_safe(), and do the right thing with h()" do
      expect_match("render_html_safe_strings", /a: foo&lt;bar, b: bar<baz, c: baz<quux, d: quux&lt;marph, e: marph>foo/)
    end
  end

  describe "streaming support" do
    # Actually trying to get streaming working completely is a VERY finicky business, and we don't want to fail
    # our tests just because (e.g.) we can't get buffering 100% disabled on this platform. So, we:
    #
    # * Use Net::HTTP to collect the HTTP/1.1 transfer chunks of the response; there should be more than one if
    #   we're actually streaming (and there ends up being just 1 if you don't tell it to stream, or if Rails
    #   detects that your template engine doesn't support streaming);
    # * Collect the rendering order server-side and output it; if streaming, we'll render the top of the layout,
    #   then the widget, then the bottom of the layout, completely differently from Rails' default mechanism of
    #   rendering the view first, then the layout.
    def collect_chunks(path)
      chunks = [ ]

      uri = rails_server.uri_for(full_path(path))
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new uri.request_uri

        http.request(request) do |response|
          response.read_body do |chunk|
            chunks << chunk
          end
        end
      end

      chunks
    end

    it "should let you stream a pure widget" do
      pending "currently, we can't figure out a way to test this for certain -- we get just one chunk no matter what we do"

      chunks = collect_chunks("stream_widget")
      expect(chunks.length).to be > 1
    end

    it "should let you stream from a widget that's in an ERb layout" do
      pending("Fortitude streaming test is not supported under Rails 3.0.x") if @rails_server.rails_version =~ /^3\.0\./
      pending("Fortitude streaming test is not supported under Ruby 1.8") if RUBY_VERSION =~ /^1\.8\./

      chunks = collect_chunks("stream_widget_with_layout")
      expect(chunks.length).to be > 1

      full_text = chunks.join("")
      expect(full_text).to match(/start_of_layout order:\s+\[:layout_start\]/mi)
      expect(full_text).to match(/end_of_widget order:\s+\[:layout_start, :widget\]/mi)
      expect(full_text).to match(/end_of_layout order:\s+\[:layout_start, :widget, :layout_end\]/mi)
    end
  end
end
