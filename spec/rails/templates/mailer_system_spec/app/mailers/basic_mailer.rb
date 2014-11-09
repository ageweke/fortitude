class BasicMailer < ActionMailer::Base
  default :from => 'nobody@example.com'

  def basic_mail
    mail(:to => 'somebody@example.com', :subject => 'Basic Mail')
  end

  def mail_with_fortitude_layout
    mail(:to => 'somebody_with_fortitude_layout@example.com', :subject => 'Basic Mail') do |format|
      format.html { render :layout => 'fortitude_layout' }
    end
  end
end
