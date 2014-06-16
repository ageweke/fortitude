class Views::HelpersSystemSpec::HelpersThatOutputWhenRefined < Fortitude::Widgets::Html5
  def content
    text "START"
    image_tag 'http://example.com/foo'
    mail_to 'test@example.com'
    stylesheet_link_tag 'http://example.com/bar'
    text "END"
  end
end
