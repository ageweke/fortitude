describe "Rails ActionMailer support", :type => :rails do
  uses_rails_with_template :mailer_system_spec

  it "should allow using Fortitude as a mailer template" do
    expect_match("send_mail", /mail sent/)
  end
end
