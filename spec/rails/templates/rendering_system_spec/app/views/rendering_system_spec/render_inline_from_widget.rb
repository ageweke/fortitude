class Views::RenderingSystemSpec::RenderInlineFromWidget < Fortitude::Widgets::Html5
  def content
    p "this is the widget"

    text = <<-EOS
widget_with_name: <%= name %>
EOS
    render :inline => text, :locals => { :name => "Fred" }
    p "this is the widget again"
  end
end
