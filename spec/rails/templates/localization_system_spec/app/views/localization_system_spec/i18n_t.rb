class Views::LocalizationSystemSpec::I18nT < Fortitude::Widget
  def content
    text "a house is: #{I18n.t(:house)}"
  end
end
