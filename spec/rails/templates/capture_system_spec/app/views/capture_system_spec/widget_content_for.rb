class Views::CaptureSystemSpec::WidgetContentFor < Fortitude::Widgets::Html5
  def content
    content_for :bar do
      h3 "this is content for bar!"
    end
    content_for :foo do
      h5 "this is content for foo!"
    end

    h4 "this is main_content!"

    content_for :foo do
      h5 "this is more content for foo!"
    end
    content_for :bar do
      h3 "this is more content for bar!"
    end
  end
end
