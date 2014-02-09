class Views::HelpersSystemSpec::BlockHelpers < Fortitude::Widget
  def content
    text(form_tag("/form_dest") do
      p "inside the form"
    end)
  end
end
