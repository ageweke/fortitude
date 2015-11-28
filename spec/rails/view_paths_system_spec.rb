describe "Rails view-path support", :type => :rails do
  uses_rails_with_template :view_paths_system_spec

  it "should be able to render a view from an added view path" do
    expect_match("added_view_path", /from an added view path/)
  end

  it "should be able to autoload classes from an added view path" do
    expect_match("autoloading_from_added_view_path", /helper method: this is base class one method one!: there it is!/)
  end
end
