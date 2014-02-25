class Views::RulesSystemSpec::InvalidlyNestedTagInPartialPartial < Fortitude::Widget
  enforce_element_nesting_rules true

  def content
    p do
      div do
        text "hi"
      end
    end
  end
end
