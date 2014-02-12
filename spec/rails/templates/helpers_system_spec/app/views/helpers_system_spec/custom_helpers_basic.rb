class Views::HelpersSystemSpec::CustomHelpersBasic < Fortitude::Widget
  def content
    text "excited: #{excitedly('awesome')}"
  end
end
