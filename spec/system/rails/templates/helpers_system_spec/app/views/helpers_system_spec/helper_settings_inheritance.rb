class Views::HelpersSystemSpec::HelperSettingsInheritance < Views::HelpersSystemSpec::HelperSettingsInheritanceParent
  helper :excitedly

  def content
    a = excitedly("awesome")
    text "it is really #{a}, yo"
    s = say_how_awesome_it_is
    text "and #{s}, too"
  end
end
