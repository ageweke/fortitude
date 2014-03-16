class Views::LocalizationSystemSpec::T < Fortitude::Widget::Html5
  def content
    text "a house is: #{t(:house)}"
  end
end
