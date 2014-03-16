class Views::LayoutsSystemSpec::YieldToViewExplicitly < Fortitude::Widget::Html5
  def content
    p "this is yield_to_view_explicitly"
  end
end
