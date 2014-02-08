describe "Rails default layout support", :type => :rails do
  uses_rails_with_template :default_layout_system_spec

  it "should let you use a default layout that's a widget, and render ERb inside it" do
    data = get("erb_with_widget_default_layout")
    data.should match(/widget_default_layout/i)
    data.should match(/erb_with_widget_default_layout/i)
  end

  it "should let you use a default layout that's a widget, and render a widget inside it" do
    data = get("widget_with_widget_default_layout")
    data.should match(/widget_default_layout/i)
    data.should match(/widget_with_widget_default_layout/i)
  end
end
