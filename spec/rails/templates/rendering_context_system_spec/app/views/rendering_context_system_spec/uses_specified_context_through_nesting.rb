class Views::RenderingContextSystemSpec::UsesSpecifiedContextThroughNesting < Fortitude::Widgets::Html5
  def content
    p "view rc: #{rendering_context.class.name}, #{rendering_context.the_value}, #{rendering_context.object_id}"
    render :partial => 'uses_specified_context_through_nesting_partial'
  end
end
