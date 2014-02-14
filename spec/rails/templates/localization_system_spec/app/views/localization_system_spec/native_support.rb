class Views::LocalizationSystemSpec::NativeSupport < Fortitude::Widget
  def content
    text "not translated; "
    ttext :awesome, :number => 127
    text "; also not translated"
  end
end
