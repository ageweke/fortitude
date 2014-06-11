class Views::LocalizationSystemSpec::DotNotation < Fortitude::Widgets::Html5
  def content
    text "awesome is: #{t(".awesome")}"
  end
end
