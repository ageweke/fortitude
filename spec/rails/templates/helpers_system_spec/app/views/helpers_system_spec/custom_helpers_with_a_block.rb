class Views::HelpersSystemSpec::CustomHelpersWithABlock < Fortitude::Widgets::Html5
  def content
    result = (reverse_it { |v| "abc#{v}def" })
    text result
  end
end
