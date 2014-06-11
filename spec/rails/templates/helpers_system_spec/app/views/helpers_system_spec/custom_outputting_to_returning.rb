class Views::HelpersSystemSpec::CustomOutputtingToReturning < Fortitude::Widgets::Html5
  helper :say_how_awesome_it_is, :transform => :return_output

  def content
    text "and #{say_how_awesome_it_is}, yo"
  end
end
