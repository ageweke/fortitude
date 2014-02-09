class Views::RenderingSystemSpec::RenderTemplateFromWidget < Fortitude::Widget
  def content
    p "this is the widget"
    # render :template => File.join(File.dirname(__FILE__), "widget_with_name"), :locals => { :name => "Fred" }
    render :template => "rendering_system_spec/widget_with_name", :locals => { :name => "Fred" }
    p "this is the widget again"
  end
end
