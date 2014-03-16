class Views::HelpersSystemSpec::ControllerHelperMethod < Fortitude::Widget::Html5
  def content
    text "it is #{decorate('Fred')}!"
  end
end
