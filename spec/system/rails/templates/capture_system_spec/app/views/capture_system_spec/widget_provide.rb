class Views::CaptureSystemSpec::WidgetProvide < Fortitude::Widget
  def content
    provide :bar do
      h3 "this is content for bar!"
    end

    h4 "this is main_content!"

    provide :foo do
      h5 "this is content for foo!"
    end
  end
end
