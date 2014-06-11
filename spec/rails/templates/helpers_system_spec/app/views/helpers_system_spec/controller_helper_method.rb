class Views::HelpersSystemSpec::ControllerHelperMethod < Fortitude::Widgets::Html5
  def content
    text "it is #{decorate('Fred')}!"
  end
end
