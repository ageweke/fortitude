class Views::HelpersSystemSpec::PrivateHelperFortitude < Fortitude::Widget
  def content
    text "a private helper: #{a_private_helper}"
  end
end
