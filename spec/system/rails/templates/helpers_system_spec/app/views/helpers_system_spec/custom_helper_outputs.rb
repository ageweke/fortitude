class Views::HelpersSystemSpec::CustomHelperOutputs < Fortitude::Widget
  def content
    text "how awesome: "
    say_how_awesome_it_is
  end
end
