class Views::HelpersSystemSpec::AutomaticHelpersInheritanceChildTwo < Views::HelpersSystemSpec::AutomaticHelpersInheritanceParent
  automatic_helper_access true

  def content
    text "C2: excitedly: "

    result = begin
      excitedly("awesome")
    rescue => e
      e.class.name
    end

    text result
    text "; "

    t = 3.months.ago
    text "time_ago_in_words: "
    result = begin
      time_ago_in_words(t)
    rescue => e
      e.class.name
    end

    text result
    text "; "

    text "number_to_currency: "
    result = begin
      number_to_currency(1_000_000)
    rescue => e
      e.class.name
    end

    text result
  end
end
