class Views::RenderingContextSystemSpec::StartEndWidgetBasic < Fortitude::Widget::Html5
  def content
    widget Views::RenderingContextSystemSpec::StartEndWidgetBasicInner.new(:value => 1)
    widget Views::RenderingContextSystemSpec::StartEndWidgetBasicInner.new(:value => 2, :inner => Views::RenderingContextSystemSpec::StartEndWidgetBasicInner)

    rendering_context.start_end_calls.each_with_index do |data, index|
      start_or_end = data[0]
      widget = data[1]
      text "#{index}: #{start_or_end} #{widget.class.name} #{widget.value if widget.respond_to?(:value)}\n"
    end
  end
end
