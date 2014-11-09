describe "Rails ActionMailer support", :type => :rails do
  uses_rails_with_template :mailer_system_spec

  it "should allow using Fortitude as a mailer template" do
    expect_match("send_mail", /mail sent/)

    mail = mail_sent_to('somebody@example.com')
    expect(mail[:body].strip).to eq("<p>this is the basic mail!</p>")
  end

  it "should allow using a Fortitude layout with a non-Fortitude view" do
    expect_match("send_mail_with_fortitude_layout_and_erb_view", /mail sent/)

    mail = mail_sent_to('somebody_with_fortitude_layout_and_erb_view@example.com')
    expect(mail[:body].strip).to match(%r{<div><p>this is the Fortitude layout</p><p>this is the mail with an ERb view!</p>\s*</div>}i)
  end

  it "should allow using a non-Fortitude layout with a Fortitude view" do
    expect_match("send_mail_with_erb_layout_and_fortitude_view", /mail sent/)

    mail = mail_sent_to('somebody_with_erb_layout_and_fortitude_view@example.com')
    expect(mail[:body].strip).to match(%r{<div><p>this is the ERb layout</p><p>this is the mail with a Fortitude view!</p>\s*</div>}i)
  end

  it "should allow using a Fortitude layout with a Fortitude view" do
    expect_match("send_mail_with_fortitude_layout", /mail sent/)

    mail = mail_sent_to('somebody_with_fortitude_layout@example.com')
    expect(mail[:body].strip).to eq("<div><p>this is the Fortitude layout</p><p>this is the mail with Fortitude layout!</p></div>")
  end
end
