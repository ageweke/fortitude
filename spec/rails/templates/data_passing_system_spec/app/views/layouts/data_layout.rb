class Views::Layouts::DataLayout < Fortitude::Widgets::Html5
  needs :foo, :bar

  def content
    html do
      head do
        title "widget_default_layout: foo = #{foo}, bar = #{bar}"
      end
      body do
        yield
      end
    end
  end
end
