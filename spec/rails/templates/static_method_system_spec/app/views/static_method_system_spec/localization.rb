class Views::StaticMethodSystemSpec::Localization < Fortitude::Widget::Html5
  def content
    text "hello is: #{t('.hello')}"
  end

  # static :content
end
