describe "basic Rails support", :type => :rails do
  uses_rails_with_template :localization_system_spec

  it "should allow you to provide localized content methods"

  it "should let you translate strings with I18n.t" do
    expect_match("i18n_t?locale=en", /a house is: house/)
    expect_match("i18n_t?locale=fr", /a house is: maison/)
  end

  it "should let you translate strings with just t" do
    expect_match("t?locale=en", /a house is: house/)
    expect_match("t?locale=fr", /a house is: maison/)
  end

  it "should let you translate strings with Fortitude translation support"
end
