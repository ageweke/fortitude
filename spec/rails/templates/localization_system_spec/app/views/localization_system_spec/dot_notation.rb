class Views::LocalizationSystemSpec::DotNotation < Fortitude::Widget::Html5
  def content
    text "awesome is: #{t(".awesome")}"
  end
end
