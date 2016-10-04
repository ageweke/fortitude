describe "Rails capture support", :type => :rails do
  uses_rails_with_template :capture_system_spec

  it "should successfully capture a widget partial with capture { } in an ERb view" do
    expect_match('capture_widget_from_erb', %r{Widget text is:\s+<h3>\s*this is some_widget</h3>\s*END}mi)
  end

  it "should successfully capture an ERb partial with capture { } in a widget" do
    expect_match('capture_erb_from_widget', %r{Widget text is:\s+<h3>\s*this is some_erb_partial</h3>\s*END}mi)
  end

  it "should successfully capture a widget with capture { } in a widget" do
    expect_match('capture_widget_from_widget', %r{Rendered with widget:\s*<h3>\s*this is another_widget rendered_with_widget</h3>.*Rendered with render_partial:\s*<h3>\s*this is another_widget rendered_with_render_partial\s*</h3>\s*END}mi)
  end

  it "should be able to provide content in a widget with content_for" do
    expect_match('widget_content_for',
      %r{erb_layout_needing_content}i,
      %r{Foo content is: <h5>this is content for foo!</h5>\s*<h5>this is more content for foo!</h5>}mi,
      %r{Main content is: <h4>this is main_content!</h4>}mi,
      %r{Bar content is: <h3>this is content for bar!</h3>\s*<h3>this is more content for bar!</h3>}mi,
      :no_layout => true)
  end

  it "should be able to provide content in a widget with provide" do
    skip "Rails 3.0.x doesn't support :provide" if rails_server.actual_rails_version =~ /^3\.0\./

    expect_match('widget_provide',
      %r{erb_layout_needing_content}i,
      %r{Foo content is: <h5>this is content for foo!</h5>}mi,
      %r{Main content is: <h4>this is main_content!</h4>}mi,
      %r{Bar content is: <h3>this is content for bar!</h3>}mi,
      :no_layout => true)
  end

  describe "should be able to retrieve stored content in a widget with yield :name" do
    it "when provided by ERb" do
      expect_match('widget_layout_needing_content_yield_with_erb',
        %r{widget_layout_needing_content}mi,
        %r{Foo content is: <h5>this is content for foo!</h5>\s*<h5>this is more content for foo!</h5>}mi,
        %r{Main content is: <h4>this is main_content!</h4>}mi,
        %r{Bar content is: <h3>this is content for bar!</h3>\s*<h3>this is more content for bar!</h3>}mi,
        :no_layout => true)
    end

    it "when provided by a widget" do
      expect_match('widget_layout_needing_content_yield_with_widget',
        %r{widget_layout_needing_content}mi,
        %r{Foo content is: <h5>this is content for foo!</h5>\s*<h5>this is more content for foo!</h5>}mi,
        %r{Main content is: <h4>this is main_content!</h4>}mi,
        %r{Bar content is: <h3>this is content for bar!</h3>\s*<h3>this is more content for bar!</h3>}mi,
        :no_layout => true)
    end
  end

  describe "should be able to retrieve stored content in a widget with content_for :name" do
    it "when provided by ERb" do
      expect_match('widget_layout_needing_content_content_for_with_erb',
        %r{widget_layout_needing_content}mi,
        %r{Foo content is: <h5>this is content for foo!</h5>\s*<h5>this is more content for foo!</h5>}mi,
        %r{Main content is: <h4>this is main_content!</h4>}mi,
        %r{Bar content is: <h3>this is content for bar!</h3>\s*<h3>this is more content for bar!</h3>}mi,
        :no_layout => true)
    end

    it "when provided by a widget" do
      expect_match('widget_layout_needing_content_content_for_with_widget',
        %r{widget_layout_needing_content}mi,
        %r{Foo content is: <h5>this is content for foo!</h5>\s*<h5>this is more content for foo!</h5>}mi,
        %r{Main content is: <h4>this is main_content!</h4>}mi,
        %r{Bar content is: <h3>this is content for bar!</h3>\s*<h3>this is more content for bar!</h3>}mi,
        :no_layout => true)
    end
  end
end
