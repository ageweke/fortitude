describe "Rails layout support", :type => :rails do
  uses_rails_with_template :layouts_system_spec

  it "should let you use a widget in an ERb layout, and render in the right order"
  it "should let you use a widget as a layout with an ERb view, and render in the right order"
  it "should let you use a widget as a layour with a widget view, and render in the right order"
  it "should let you select the layout"
end
