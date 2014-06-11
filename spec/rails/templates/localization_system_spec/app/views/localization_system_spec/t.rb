class Views::LocalizationSystemSpec::T < Fortitude::Widgets::Html5
  def content
    text "a house is: #{t(:house)}"
  end
end
