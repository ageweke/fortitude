class Views::RenderingContextSystemSpec::StartEndWidgetThroughPartials < Fortitude::Widgets::Html5
  def content
    render :partial => 'start_end_widget_through_partials_partial'

    rendering_context.start_end_calls.each_with_index do |data, index|
      start_or_end = data[0]
      widget = data[1]
      widget_data = if widget.kind_of?(Array)
        widget.inspect
      else
        widget.class.name
      end
      rawtext "#{index}: #{start_or_end} #{widget_data} #{widget.value if widget.respond_to?(:value)}\n"
    end
  end
end
