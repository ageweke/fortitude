class Views::CaptureSystemSpec::WidgetContentFor < Fortitude::Widget
  def content
    content_for :bar do
      h3 "this is content for bar!"
    end

    h4 "this is main_content!"

    content_for :foo do
      h5 "this is content for foo!"
    end
  end
end
