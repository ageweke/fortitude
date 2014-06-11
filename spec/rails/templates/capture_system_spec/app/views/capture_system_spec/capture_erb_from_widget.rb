class Views::CaptureSystemSpec::CaptureErbFromWidget < Fortitude::Widgets::Html5
  def content
    widget_text = capture do
      render :partial => 'some_erb_partial'
    end

    text "Widget text is: "
    text widget_text
    text "END"
  end
end
