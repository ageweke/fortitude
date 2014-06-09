class Views::ProductionModeSystemSpec::SampleOutput < Fortitude::Widget::Html5
  needs :name

  def content
    section(:class => 'one') do
      p "hello, #{name}"
    end
  end
end
