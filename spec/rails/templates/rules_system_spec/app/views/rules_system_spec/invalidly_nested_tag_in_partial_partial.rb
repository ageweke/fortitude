class Views::RulesSystemSpec::InvalidlyNestedTagInPartialPartial < Fortitude::Widget::Html5
  enforce_element_nesting_rules true

  def content
    p do
      div do
        text "hi"
      end
    end
  end
end
