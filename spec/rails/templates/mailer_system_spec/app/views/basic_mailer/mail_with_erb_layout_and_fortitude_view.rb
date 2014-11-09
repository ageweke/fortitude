class Views::BasicMailer::MailWithErbLayoutAndFortitudeView < Fortitude::Widgets::Html5
  def content
    p "this is the mail with a Fortitude view!"
  end
end
