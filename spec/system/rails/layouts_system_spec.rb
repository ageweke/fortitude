describe "Rails layout support", :type => :rails do
  uses_rails_with_template :layouts_system_spec

  it "should let you use a widget in an ERb layout, and render in the right order" do
    data = get("widget_inside_erb_layout")
    data.should match(/default_layout_erb/i)
    data.should match(/this is widget_inside_erb_layout/i)
    data.should match(/pre_layout order: \[:widget_inside_erb_layout, :layout_pre\]/i)
    data.should match(/post_layout order: \[:widget_inside_erb_layout, :layout_pre, :layout_post\]/i)
    data.should match(/order inside widget: \[:widget_inside_erb_layout\]/i)
    data.should match(/pre_layout foo: foo_from_widget_inside_erb_layout/i)
    data.should match(/post_layout foo: foo_from_widget_inside_erb_layout/i)
  end

  it "should let you use a widget as a layout with an ERb view, and render in the right order"
  it "should let you use a widget as a layour with a widget view, and render in the right order"
  it "should let you select the layout"

  it "should use a layout with render :widget by default"
  it "should let you turn off the layout with render :widget"
  it "should let you pick an alternate layout for render :widget"
end
