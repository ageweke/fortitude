class Views::Layouts::MailLayout < Fortitude::Widgets::Html5
  def content
    p "this is the layout, before"
    yield
    p "this is the layout, after"
  end
end
