class Views::HelpersSystemSpec::PrivateHelperFortitude < Fortitude::Widgets::Html5
  def content
    text "a private helper: #{a_private_helper}"
  end
end
