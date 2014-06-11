class Views::CaptureSystemSpec::CaptureWidgetFromWidget < Fortitude::Widgets::Html5
  def content
    widget_text_1 = capture do
      widget Views::CaptureSystemSpec::AnotherWidget.new(:name => "rendered_with_widget")
    end

    widget_text_2 = capture do
      render :partial => 'another_widget', :locals => { :name => "rendered_with_render_partial" }
    end

    text "Rendered with widget:"
    text widget_text_1
    text "Rendered with render_partial:"
    text widget_text_2
    text "END"
  end
end
