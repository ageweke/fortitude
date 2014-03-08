class Views::RenderingContextSystemSpec::UsesDirectContextForAllWidgets < Fortitude::Widget
  def content
    p "context is: #{rendering_context.class.name}, value #{rendering_context.the_value}"
    render :partial => 'uses_direct_context_for_all_widgets_partial'
    widget Views::RenderingContextSystemSpec::UsesDirectContextForAllWidgetsWidget.new
  end
end
