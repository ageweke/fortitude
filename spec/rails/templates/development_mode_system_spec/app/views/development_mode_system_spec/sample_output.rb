class Views::DevelopmentModeSystemSpec::SampleOutput < Fortitude::Widgets::Html5
  needs :name

  def content
    section(:class => 'one') do
      p "hello, #{name}"
    end
  end
end
