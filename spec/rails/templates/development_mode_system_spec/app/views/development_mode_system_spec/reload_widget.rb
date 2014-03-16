class Views::DevelopmentModeSystemSpec::ReloadWidget < Fortitude::Widget::Html5
  needs :datum

  def content
    p "before_reload: datum #{datum} datum"
  end
end
