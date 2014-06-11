class Views::RenderingSystemSpec::RenderTemplateFromWidget < Fortitude::Widgets::Html5
  def content
    p "this is the widget"
    render :template => "rendering_system_spec/widget_with_name", :locals => { :name => "Fred" }
    p "this is the widget again"
  end
end
