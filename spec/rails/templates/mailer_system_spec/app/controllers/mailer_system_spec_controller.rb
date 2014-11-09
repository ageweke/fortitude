class MailerSystemSpecController < ApplicationController
  def send_mail
    BasicMailer.basic_mail.deliver
  end

  def send_mail_with_fortitude_layout
    BasicMailer.mail_with_fortitude_layout.deliver
  end
end
