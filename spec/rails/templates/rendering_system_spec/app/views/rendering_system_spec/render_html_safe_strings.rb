class Views::RenderingSystemSpec::RenderHtmlSafeStrings < Fortitude::Widget::Html5
  needs :a, :b, :c, :d, :e

  def content
    text "a: "
    text a
    text ", b: "
    text b
    text ", c: "
    text raw(c)
    text ", d: "
    rawtext h(d)
    text ", e: "
    text h(e)
  end
end
