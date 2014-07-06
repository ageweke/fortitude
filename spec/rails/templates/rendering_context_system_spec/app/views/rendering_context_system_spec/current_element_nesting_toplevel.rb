class Views::RenderingContextSystemSpec::CurrentElementNestingToplevel < Fortitude::Widgets::Html5
  record_tag_emission true

  def content
    div {
      render :partial => 'current_element_nesting_intermediate'
    }
  end
end
