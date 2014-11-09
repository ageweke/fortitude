class MailerSystemSpecController < ApplicationController
  def send_mail
    BasicMailer.basic_mail.deliver
  end

  def send_mail_with_fortitude_layout
    BasicMailer.mail_with_fortitude_layout.deliver
  end

  def send_mail_with_fortitude_layout_and_erb_view
    BasicMailer.mail_with_fortitude_layout_and_erb_view.deliver
  end

  def send_mail_with_erb_layout_and_fortitude_view
    BasicMailer.mail_with_erb_layout_and_fortitude_view.deliver
  end
end
