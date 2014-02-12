class Views::RenderingSystemSpec::RenderTextFromWidget < Fortitude::Widget
  def content
    p "this is the widget"
    render :text => "this is render_text"
    p "this is the widget again"
  end
end
