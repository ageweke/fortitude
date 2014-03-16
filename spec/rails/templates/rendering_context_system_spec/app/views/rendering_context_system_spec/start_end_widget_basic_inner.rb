class Views::RenderingContextSystemSpec::StartEndWidgetBasicInner < Fortitude::Widget::Html5
  needs :inner => nil, :value => nil

  def content
    widget inner.new if inner
  end
end
