class Views::HelpersSystemSpec::BuiltInOutputtingToReturning < Fortitude::Widgets::Html5
  helper :concat, :transform => :return_output

  def content
    the_text = concat("this is the_text")
    p "text is: #{the_text}"
  end
end
