describe "Rails ActionMailer support", :type => :rails do
  uses_rails_with_template :mailer_system_spec

  it "should allow using Fortitude as a mailer template" do
    expect_match("send_mail", /mail sent/)

    mail = mail_sent_to('somebody@example.com')
    expect(mail[:body].strip).to eq("<p>this is the basic mail!</p>")
  end

  it "should allow using a Fortitude layout with a non-Fortitude view"
  it "should allow using a non-Fortitude layout with a Fortitude view"
  it "should allow using a Fortitude layout with a Fortitude view"
end
