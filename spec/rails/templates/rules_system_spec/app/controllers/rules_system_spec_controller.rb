class RulesSystemSpecController < ApplicationController
  def invalidly_nested_tag
    # nothing here
  end

  def invalidly_nested_tag_in_partial
    # nothing here
  end

  def invalid_start_tag_in_partial
    # nothing here
  end

  def invalid_start_tag_in_view
    # nothing here
    render :layout => 'fortitude_layout_with_p'
  end

  def intervening_partial
    # nothing here
  end
end
