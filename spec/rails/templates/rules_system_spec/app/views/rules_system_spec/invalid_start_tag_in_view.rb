class Views::RulesSystemSpec::InvalidStartTagInView < Fortitude::Widgets::Html5
  enforce_element_nesting_rules true

  def content
    div do
      text "we got there!"
    end
  end
end
