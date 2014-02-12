class Views::RenderingSystemSpec::StreamWidget < Fortitude::Widget
  def content
    $order << :widget if $order

    p "About to sleep"
    sleep 0.1
    p "Slept once"
    sleep 0.1
    p "Slept again"

    p "end_of_widget order: #{$order.inspect}"
  end
end
