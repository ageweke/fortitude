class Views::DevelopmentModeSystemSpec::ReloadWidget < Fortitude::Widget
  needs :datum

  def content
    p "before_reload: datum #{datum} datum"
  end
end
