describe "Rails helper support", :type => :rails do
  uses_rails_with_template :helpers_system_spec

  it "should support the built-in Rails helpers by default"
  it "should support both rendered and unrendered helpers properly"
  it "should support custom-defined helpers"
  it "should automatically expose helpers in app/helpers just like Rails does"
  it "should allow turning off automatic loading of helpers from app/helpers"
end
