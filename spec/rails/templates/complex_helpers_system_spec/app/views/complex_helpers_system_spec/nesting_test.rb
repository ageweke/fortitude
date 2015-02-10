class Views::ComplexHelpersSystemSpec::NestingTest < Fortitude::Widgets::Html5
  def content
    text "OUTSIDE_BEFORE"
    form_for :person do |f|
      text "INSIDE_FORM_BEFORE"
      text "FIRST: "
      f.text_field :first_name

      f.fields_for :whatsit do |w|
        text "WHATSIT BAR: "
        w.text_field :bar
        text "AFTER WHATSIT BAR"
      end

      text "LAST: "
      f.text_field :last_name
      text "INSIDE_FORM_AFTER"
    end
    text "OUTSIDE_AFTER"
  end
end
