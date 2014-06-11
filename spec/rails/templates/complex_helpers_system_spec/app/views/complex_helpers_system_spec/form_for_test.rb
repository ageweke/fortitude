class Views::ComplexHelpersSystemSpec::FormForTest < Fortitude::Widgets::Html5
  def content
    text "OUTSIDE_BEFORE"
    form_for :person do |f|
      text "INSIDE_BEFORE"
      text "FIRST: "
      f.text_field :first_name
      text "LAST: "
      f.text_field :last_name
      text "INSIDE_AFTER"
    end
    text "OUTSIDE_AFTER"
  end
end
