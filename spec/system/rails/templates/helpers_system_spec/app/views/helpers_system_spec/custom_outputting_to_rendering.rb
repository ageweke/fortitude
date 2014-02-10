class Views::HelpersSystemSpec::CustomOutputtingToRendering < Fortitude::Widget
  helper :excitedly, :transform => :output_return_value

  def content
    text "and: "
    excitedly("awesome")
    text ", yo"
  end
end
