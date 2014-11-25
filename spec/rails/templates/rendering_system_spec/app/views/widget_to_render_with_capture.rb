class Views::WidgetToRenderWithCapture < ::Fortitude::Widgets::Html5
  def content
    x = nil

    p(:class => 'one') {
      text "before_capture"
      x = capture {
        p "inside_capture"
      }
      text "after_capture"
    }

    p(:class => 'two') {
      text "before_splat"
      rawtext(x)
      text "after_splat"
    }
  end
end
