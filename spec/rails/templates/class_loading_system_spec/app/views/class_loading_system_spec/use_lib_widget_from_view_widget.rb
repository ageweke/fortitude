require 'views/lib_widget'

class Views::ClassLoadingSystemSpec::UseLibWidgetFromViewWidget < Fortitude::Widgets::Html5
  def content
    p "about to run the lib widget"
    widget Views::LibWidget.new
    p "ran the lib widget"
  end
end
