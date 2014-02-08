class Views::RenderingSystemSpec::RenderPartialFromWidget < Fortitude::Widget
  def content
    p "this is the widget"
    render :partial => 'the_partial'
    p "this is the widget again"
  end
end
