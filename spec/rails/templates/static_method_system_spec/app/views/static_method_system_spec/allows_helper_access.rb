class Views::StaticMethodSystemSpec::AllowsHelperAccess < Fortitude::Widget
  def content
    text "foo is: #{foo('aaa')}"
    bar('bbb')
  end

  static :content
end
