class Views::DataPassingSystemSpec::PassingLocalsWidget < Fortitude::Widget::Html5
  needs :foo, :bar

  def content
    p "foo is: #{foo}"
    p "bar is: #{bar}"
  end
end
