class Views::HelpersSystemSpec::AutomaticHelpersInheritance < Fortitude::Widgets::Html5
  def content
    widget Views::HelpersSystemSpec::AutomaticHelpersInheritanceChildOne.new
    widget Views::HelpersSystemSpec::AutomaticHelpersInheritanceChildTwo.new
  end
end
