class Views::LocalizationSystemSpec::NativeSupport < Fortitude::Widgets::Html5
  def content
    text "not translated; "
    ttext :awesome, :number => 127
    text "; also not translated"
  end
end
