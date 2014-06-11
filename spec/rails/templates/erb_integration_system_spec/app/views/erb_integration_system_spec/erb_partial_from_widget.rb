class Views::ErbIntegrationSystemSpec::ErbPartialFromWidget < Fortitude::Widgets::Html5
  def content
    p "this is the widget"
    render :partial => 'erb_partial_from_widget_partial'
    p "this is the widget again"
  end
end
