class Views::RulesSystemSpec::InterveningPartial < Fortitude::Widget
  enforce_element_nesting_rules true

  def content
    p do
      render :partial => 'intervening_partial_erb_partial'
    end
  end
end
