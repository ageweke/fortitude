class Views::RenderingSystemSpec::Word < Fortitude::Widget::Html5
  needs :word

  def content
    text "word: #{word}"
  end
end
