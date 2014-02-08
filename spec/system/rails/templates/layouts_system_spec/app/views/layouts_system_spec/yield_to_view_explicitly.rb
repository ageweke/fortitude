class Views::LayoutsSystemSpec::YieldToViewExplicitly < Fortitude::Widget
  def content
    p "this is yield_to_view_explicitly"
  end
end
