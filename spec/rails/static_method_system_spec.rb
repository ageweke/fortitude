describe "Fortitude static-method behavior in Rails", :type => :rails do
  uses_rails_with_template :static_method_system_spec

  it "should allow access to helpers in methods made static"
end
