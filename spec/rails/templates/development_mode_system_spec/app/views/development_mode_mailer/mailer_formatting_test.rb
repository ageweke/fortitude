class Views::DevelopmentModeMailer::MailerFormattingTest < Fortitude::Widgets::Html5
  def content
    div {
      p "this is the text!"
    }
  end
end
