class Views::RulesSystemSpec::InvalidStartTagInPartialPartial < Fortitude::Widget
  enforce_element_nesting_rules true

  def content
    div do
      text "we got there!"
    end
  end
end
