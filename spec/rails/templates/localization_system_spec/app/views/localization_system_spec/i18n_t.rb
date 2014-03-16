class Views::LocalizationSystemSpec::I18nT < Fortitude::Widget::Html5
  def content
    text "a house is: #{I18n.t(:house)}"
  end
end
