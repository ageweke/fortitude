describe "Rails ERb integration support", :type => :rails do
  uses_rails_with_template :erb_integration_system_spec

  it "should let you call a widget from an ERb file with render :partial" do
    expect_match("erb_to_widget_with_render_partial", /erb to widget with render partial widget/,
      /erb_start/, /erb_end/, /erb_start.*erb to widget with render partial widget.*erb_end/m)
  end

  it "should let you call a widget from an ERb file with widget" do
    expect_match("erb_to_widget_with_widget", /erb to widget with widget widget/,
      /erb_start/, /erb_end/, /erb_start.*erb to widget with widget widget, name Josephine.*erb_end/m)
  end

  it "should let you call a widget from an ERb file with widget, passing the class" do
    expect_match("erb_to_widget_with_widget_class", /erb to widget with widget widget/,
      /erb_start/, /erb_end/, /erb_start.*erb to widget with widget widget, name Josephine.*erb_end/m)
  end

  it "should prefer ERb partials to Fortitude partials" do
    expect_match("prefers_erb_partial", /erb partial/,
      /erb_start.*erb partial.*erb_end/m)
  end

  it "should allow you to define a Fortitude partial in a file with an underscore" do
    expect_match('fortitude_partial_with_underscore', /fortitude partial with underscore partial/,
      /erb_start.*fortitude partial with underscore partial.*erb_end/m)
  end

  it "should let you call an ERb partial from a widget with render :partial" do
    expect_match('erb_partial_from_widget',
      /this is the widget.*this is the partial.*this is the widget again/mi)
  end
end
