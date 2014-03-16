class Views::DataPassingSystemSpec::ParentToChildPassingPartial < Fortitude::Widget::Html5
  def content
    p "parent before"
    render :partial => 'parent_to_child_passing_partial_child'
    p "parent after"
  end
end
