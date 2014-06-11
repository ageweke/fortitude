class Views::HelpersSystemSpec::CustomHelpersBasic < Fortitude::Widgets::Html5
  def content
    text "excited: #{excitedly('awesome')}"
  end
end
