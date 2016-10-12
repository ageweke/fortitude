describe "Rails view-path support", :type => :rails do
  uses_rails_with_template :view_paths_system_spec

  it "should be able to render a view from an added view path" do
    expect_match("added_view_path", /from an added view path/)
  end

  it "should be able to autoload classes from an added view path" do
    expect_match("autoloading_from_added_view_path", /helper method: this is base class one method one!: there it is!/)
  end

  it "should be able to render a view from an added view path from the controller" do
    expect_match("added_view_path_from_controller", /from an added view path from the controller/)
  end

  it "should be able to render a view from an added view path from the controller with an impossible-to-guess name" do
    expect_match("added_view_path_from_controller_with_impossible_to_guess_name", /from an added view path from the controller with an impossible-to-guess name/)
  end
end
