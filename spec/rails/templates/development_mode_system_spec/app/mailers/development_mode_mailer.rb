class DevelopmentModeMailer < ActionMailer::Base
  default :from => 'nobody@example.com'

  def mailer_view_test
    mail(:to => 'mailer_view_test@example.com', :subject => 'Mailer View Test')
  end

  def mailer_layout_test
    mail(:to => 'mailer_layout_test@example.com', :subject => 'Mailer Layout Test') do |format|
      format.html { render :layout => 'mail_layout' }
    end
  end

  def mailer_formatting_test
    mail(:to => 'mailer_formatting_test@example.com', :subject => 'Mailer Formatting Test')
  end
end
