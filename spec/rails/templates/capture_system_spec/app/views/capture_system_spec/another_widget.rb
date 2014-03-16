class Views::CaptureSystemSpec::AnotherWidget < Fortitude::Widget::Html5
  needs :name

  def content
    h3 "this is another_widget #{name}"
  end
end
