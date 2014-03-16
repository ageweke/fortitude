class Views::HelpersSystemSpec::CustomReturningToOutputting < Fortitude::Widget::Html5
  helper :excitedly, :transform => :output_return_value

  def content
    text "and "
    retval = excitedly("awesome")
    text ", yo"
    text retval
  end
end
