class Views::HelpersSystemSpec::ControllerHelperMethod < Fortitude::Widget
  def content
    text "it is #{decorate('Fred')}!"
  end
end
