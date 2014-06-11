class Views::RenderingSystemSpec::RenderFileFromWidget < Fortitude::Widgets::Html5
  def content
    p "this is the widget"
    render :file => File.join(File.dirname(__FILE__), "widget_with_name"), :locals => { :name => "Fred" }
    p "this is the widget again"
  end
end
