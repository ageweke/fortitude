class Views::ComplexHelpersSystemSpec::LabelBlockTest < Fortitude::Widgets::Html5
  def content
    form_for :person do |f|
      f.label(:name) do
        text 'Foo'
      end
    end
  end
end
