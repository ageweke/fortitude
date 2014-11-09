class MailerSystemSpecController < ApplicationController
  def send_mail
    BasicMailer.basic_mail.deliver
  end
end
