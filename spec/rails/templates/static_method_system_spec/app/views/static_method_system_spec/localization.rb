class Views::StaticMethodSystemSpec::Localization < Fortitude::Widgets::Html5
  def content
    text "hello is: #{t('.hello')}"
  end

  static :content
end
