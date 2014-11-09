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

  def mail_with_fortitude_layout_and_erb_view
    mail(:to => 'somebody_with_fortitude_layout_and_erb_view@example.com', :subject => 'Basic Mail') do |format|
      format.html { render :layout => 'fortitude_layout' }
    end
  end

  def mail_with_erb_layout_and_fortitude_view
    mail(:to => 'somebody_with_erb_layout_and_fortitude_view@example.com', :subject => 'Basic Mail') do |format|
      format.html { render :layout => 'erb_layout' }
    end
  end
end
