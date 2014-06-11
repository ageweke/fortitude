class Views::RenderingContextSystemSpec::UsesSpecifiedContextThroughNestingInnerPartial < Fortitude::Widgets::Html5
  def content
    p "inner partial rc: #{rendering_context.class.name}, #{rendering_context.the_value}, #{rendering_context.object_id}"
  end
end
