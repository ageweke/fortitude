class Views::Layouts::ExplicitYield < Fortitude::Widget::Html5
  def content
    html do
      head do
        title "explicit_yield_layout"
      end
      body do
        yield_from_widget
      end
    end
  end
end
