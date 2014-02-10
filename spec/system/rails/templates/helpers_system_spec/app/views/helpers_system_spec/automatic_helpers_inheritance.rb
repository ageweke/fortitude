class Views::HelpersSystemSpec::AutomaticHelpersInheritance < Fortitude::Widget
  def content
    widget Views::HelpersSystemSpec::AutomaticHelpersInheritanceChildOne.new
    widget Views::HelpersSystemSpec::AutomaticHelpersInheritanceChildTwo.new
  end
end
