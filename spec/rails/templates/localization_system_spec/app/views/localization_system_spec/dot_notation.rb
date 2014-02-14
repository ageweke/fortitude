class Views::LocalizationSystemSpec::DotNotation < Fortitude::Widget
  def content
    text "awesome is: #{t(".awesome")}"
  end
end
