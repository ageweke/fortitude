class Views::HelpersSystemSpec::BlockHelpers < Fortitude::Widget::Html5
  def content
    form_tag("/form_dest") do
      p "inside the form"
    end
  end
end
