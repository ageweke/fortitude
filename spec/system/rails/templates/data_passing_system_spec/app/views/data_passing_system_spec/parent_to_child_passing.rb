class Views::DataPassingSystemSpec::ParentToChildPassing < Fortitude::Widget
  def content
    p "parent before"
    widget Views::DataPassingSystemSpec::ParentToChildPassingChild.new
    p "parent after"
  end
end
