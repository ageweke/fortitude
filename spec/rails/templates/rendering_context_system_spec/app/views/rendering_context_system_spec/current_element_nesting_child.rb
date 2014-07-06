class Views::RenderingContextSystemSpec::CurrentElementNestingChild < Fortitude::Widgets::Html5
  record_tag_emission true

  def content
    p {
      rendering_context.current_element_nesting.each_with_index do |item, index|
        name_text = ""
        name_text = "/#{item.name.inspect}" if item.respond_to?(:name)
        text "#{index}: [#{item.class.name}#{name_text}]\n"
      end
    }
  end
end
