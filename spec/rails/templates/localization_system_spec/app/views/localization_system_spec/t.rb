class Views::LocalizationSystemSpec::T < Fortitude::Widget
  def content
    text "a house is: #{t(:house)}"
  end
end
