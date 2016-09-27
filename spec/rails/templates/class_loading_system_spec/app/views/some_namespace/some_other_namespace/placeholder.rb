class Views::SomeNamespace::SomeOtherNamespace::Placeholder < Fortitude::Widgets::Html5
  def content
    raise "this should never be called"
  end
end
