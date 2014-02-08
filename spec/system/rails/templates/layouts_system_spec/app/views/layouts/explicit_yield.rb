class Views::Layouts::ExplicitYield < Fortitude::Widget
  def content
    html do
      head do
        title "explicit_yield_layout"
      end
      body do
        yield_to_view
      end
    end
  end
end
