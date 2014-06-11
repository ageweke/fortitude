class Views::RulesSystemSpec::InvalidStartTagInPartialPartial < Fortitude::Widgets::Html5
  enforce_element_nesting_rules true

  def content
    div do
      text "we got there!"
    end
  end
end
