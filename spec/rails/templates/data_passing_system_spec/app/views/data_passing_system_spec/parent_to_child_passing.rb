class Views::DataPassingSystemSpec::ParentToChildPassing < Fortitude::Widgets::Html5
  def content
    p "parent before"
    widget Views::DataPassingSystemSpec::ParentToChildPassingChild.new
    p "parent after"
  end
end
