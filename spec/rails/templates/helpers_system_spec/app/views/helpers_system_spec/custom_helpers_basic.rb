class Views::HelpersSystemSpec::CustomHelpersBasic < Fortitude::Widget::Html5
  def content
    text "excited: #{excitedly('awesome')}"
  end
end
