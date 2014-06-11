class Views::DevelopmentModeSystemSpec::ReloadWidget < Fortitude::Widgets::Html5
  needs :datum

  def content
    p "before_reload: datum #{datum} datum"
  end
end
