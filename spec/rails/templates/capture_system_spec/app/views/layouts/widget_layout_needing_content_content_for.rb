class Views::Layouts::WidgetLayoutNeedingContentContentFor < Fortitude::Widgets::Html5
  def content
    html {
      head {
        title "widget_layout_needing_content"
      }
      body {
        p {
          text "Foo content is: "
          text(content_for :foo)
        }
        p {
          text "Main content is: "
          yield
        }
        p {
          text "Bar content is: "
          text(content_for :bar)
        }
      }
    }
  end
end
