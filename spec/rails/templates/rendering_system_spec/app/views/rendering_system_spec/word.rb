class Views::RenderingSystemSpec::Word < Fortitude::Widget
  needs :word

  def content
    text "word: #{word}"
  end
end
