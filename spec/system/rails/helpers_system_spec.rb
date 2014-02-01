describe "Rails helper support", :type => :rails do
  uses_rails_with_template :helpers_system_spec

  it "should support the built-in Rails helpers by default"
  it "should support both rendered and unrendered helpers properly"
  it "should support custom-defined helpers"
end
