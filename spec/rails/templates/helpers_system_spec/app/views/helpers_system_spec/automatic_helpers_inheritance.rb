class Views::HelpersSystemSpec::AutomaticHelpersInheritance < Fortitude::Widget::Html5
  def content
    widget Views::HelpersSystemSpec::AutomaticHelpersInheritanceChildOne.new
    widget Views::HelpersSystemSpec::AutomaticHelpersInheritanceChildTwo.new
  end
end
