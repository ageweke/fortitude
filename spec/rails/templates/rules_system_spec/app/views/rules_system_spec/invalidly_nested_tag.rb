class Views::RulesSystemSpec::InvalidlyNestedTag < Fortitude::Widget
  enforce_element_nesting_rules true

  def content
    p do
      div do
        text "hi"
      end
    end
  end
end
