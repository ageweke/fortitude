class Views::StaticMethodSystemSpec::Localization < Fortitude::Widget
  def content
    text "hello is: #{t('.hello')}"
  end

  # static :content
end
