class Views::StaticMethodSystemSpec::AllowsHelperAccess < Fortitude::Widgets::Html5
  def content
    text "foo is: #{foo('aaa')}"
    bar('bbb')
  end

  static :content
end
