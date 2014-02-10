class Views::HelpersSystemSpec::BuiltInRenderingToOutputting < Fortitude::Widget
  helper :time_ago_in_words, :transform => :output_return_value

  def content
    t = 3.months.ago
    text "it was "
    retval = time_ago_in_words(t)
    text ", yo"
  end
end
