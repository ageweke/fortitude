describe "basic Rails support", :type => :rails do
  uses_rails_with_template :localization_system_spec

  it "should allow you to provide localized widgets"
  it "should let you translate strings with I18n.t"
  it "should let you translate strings with just t"
  it "should let you translate strings with Fortitude translation support"
  it "should let you provide localized widgets"
end
