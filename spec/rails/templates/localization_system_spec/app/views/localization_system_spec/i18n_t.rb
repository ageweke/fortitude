class Views::LocalizationSystemSpec::I18nT < Fortitude::Widgets::Html5
  def content
    text "a house is: #{I18n.t(:house)}"
  end
end
