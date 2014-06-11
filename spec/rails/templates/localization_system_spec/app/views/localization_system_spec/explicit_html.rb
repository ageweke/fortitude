class Views::LocalizationSystemSpec::ExplicitHtml < Fortitude::Widgets::Html5
  def content
    text "one: "
    text t(:one_html)
    text ", two: "
    text t("two.html")

    text ", one again: "
    ttext(:one_html)
    text ", two again: "
    ttext("two.html")
  end
end
