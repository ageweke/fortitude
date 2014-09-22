describe "basic Rails support", :type => :rails do
  uses_rails_with_template :basic_rails_system_spec

  it "should be able to render a trivial widget" do
    expect_match("trivial_widget", /layout_default/, /hello, world/)
  end

  it "should be able to use 'render' more than once in an action, and it should work fine" do
    expect_match("double_render", /layout_default/, /hello, world.*goodbye, world.*and this is the last partial\!/mi)
  end
end
