class Views::RulesSystemSpec::InvalidStartTagInView < Fortitude::Widget
  enforce_element_nesting_rules true

  def content
    div do
      text "we got there!"
    end
  end
end
