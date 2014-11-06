class Views::Layouts::FortitudeLayoutWithP < Fortitude::Widgets::Html5
  doctype :html5
  enforce_element_nesting_rules true

  def content
    doctype!

    html {
      head {
        title "oop_rails_server_base_template"
      }
    }
    body {
      p {
        yield
      }
    }
  end
end
