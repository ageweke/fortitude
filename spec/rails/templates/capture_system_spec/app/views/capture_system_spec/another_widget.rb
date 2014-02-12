class Views::CaptureSystemSpec::AnotherWidget < Fortitude::Widget
  needs :name

  def content
    h3 "this is another_widget #{name}"
  end
end
