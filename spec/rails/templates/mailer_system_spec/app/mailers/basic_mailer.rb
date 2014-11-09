class BasicMailer < ActionMailer::Base
  default :from => 'nobody@example.com'

  def basic_mail
    mail(:to => 'somebody@example.com', :subject => 'Basic Mail')
  end
end
