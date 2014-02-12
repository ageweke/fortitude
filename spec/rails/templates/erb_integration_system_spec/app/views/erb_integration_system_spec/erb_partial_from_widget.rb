class Views::ErbIntegrationSystemSpec::ErbPartialFromWidget < Fortitude::Widget
  def content
    p "this is the widget"
    render :partial => 'erb_partial_from_widget_partial'
    p "this is the widget again"
  end
end
