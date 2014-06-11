class Views::DataPassingSystemSpec::ImplicitVariableRead < Fortitude::Widgets::Html5
  def content
    widget Views::DataPassingSystemSpec::ImplicitVariableReadInner.new
  end
end
