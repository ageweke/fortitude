class Views::HelpersSystemSpec::HelperSettingsInheritanceParent < Fortitude::Widget
  helper :excitedly, :transform => :output_return_value
  helper :say_how_awesome_it_is, :transform => :return_output
end
