class Views::ComplexHelpersSystemSpec::LabelBlockTest < Fortitude::Widgets::Html5
  def content

    form_for :person do |f|
      1 == 2
      f.label(:name) do
        text 'Foo'
      end

    end
  end
end
