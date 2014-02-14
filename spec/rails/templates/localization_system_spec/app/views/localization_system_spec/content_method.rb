class Views::LocalizationSystemSpec::ContentMethod < Fortitude::Widget
  def localized_content_en
    text "wassup? this is english"
  end

  def localized_content_fr
    text "bienvenue, les mecs"
  end

  def content
    text "i don't know that language"
  end
end
