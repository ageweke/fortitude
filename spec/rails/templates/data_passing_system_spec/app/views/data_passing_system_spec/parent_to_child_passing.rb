class Views::DataPassingSystemSpec::ParentToChildPassing < Fortitude::Widget::Html5
  def content
    p "parent before"
    widget Views::DataPassingSystemSpec::ParentToChildPassingChild.new
    p "parent after"
  end
end
