class Views::RenderingContextSystemSpec::UsesSpecifiedContextInView < Fortitude::Widget
  def content
    p "context is: #{rendering_context.class.name}, value #{rendering_context.the_value}"
  end
end
