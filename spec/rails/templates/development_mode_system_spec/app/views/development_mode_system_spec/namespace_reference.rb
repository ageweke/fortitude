class Views::DevelopmentModeSystemSpec::NamespaceReference < Fortitude::Widgets::Html5
  def content
    p "before"
    widget ReferencedWidget
    p "after"
  end
end
