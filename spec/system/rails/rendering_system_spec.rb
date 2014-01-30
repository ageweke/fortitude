describe "Rails rendering support", :type => :rails do
  uses_rails_with_template :rendering_system_spec

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
