class Views::HelpersUnrefinedSystemSpec::HelpersThatOutputWhenRefined < Fortitude::Widget::Html5
  def content
    text "START"
    image_tag 'foo'
    mail_to 'test@example.com'
    stylesheet_link_tag 'bar'
    text "END"
  end
end
