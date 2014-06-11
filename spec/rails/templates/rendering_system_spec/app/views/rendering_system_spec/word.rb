class Views::RenderingSystemSpec::Word < Fortitude::Widgets::Html5
  needs :word

  def content
    text "word: #{word}"
  end
end
