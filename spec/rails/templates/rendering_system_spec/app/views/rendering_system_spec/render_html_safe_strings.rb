class Views::RenderingSystemSpec::RenderHtmlSafeStrings < Fortitude::Widget::Html5
  needs :a, :b, :c

  def content
    text "a: "
    text a
    text ", b: "
    text b
    text ", c: "
    text raw(c)
  end
end
