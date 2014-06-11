class Views::RenderingContextSystemSpec::UsesDirectContextForAllWidgetsWidget < Fortitude::Widgets::Html5
  def content
    p "context is: #{rendering_context.class.name}, value #{rendering_context.the_value}"
  end
end
