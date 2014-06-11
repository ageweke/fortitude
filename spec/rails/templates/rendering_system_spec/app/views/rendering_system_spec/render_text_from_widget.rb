class Views::RenderingSystemSpec::RenderTextFromWidget < Fortitude::Widgets::Html5
  def content
    p "this is the widget"
    render :text => "this is render_text"
    p "this is the widget again"
  end
end
