class Views::Layouts::WidgetLayoutNeedingContentYield < Fortitude::Widget::Html5
  def content
    html {
      head {
        title "widget_layout_needing_content"
      }
      body {
        p {
          text "Foo content is: "
          yield :foo
        }
        p {
          text "Main content is: "
          yield
        }
        p {
          text "Bar content is: "
          yield :bar
        }
      }
    }
  end
end
