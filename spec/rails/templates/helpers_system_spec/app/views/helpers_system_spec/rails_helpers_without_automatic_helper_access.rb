class Views::HelpersSystemSpec::RailsHelpersWithoutAutomaticHelperAccess < Fortitude::Widgets::Html5
  automatic_helper_access false

  def content
    three_months_value = begin
      distance_of_time_in_words_to_now(3.months.ago)
    rescue => e
      e.class.name
    end

    million_dollars_value = begin
      number_to_currency(1_000_000.00)
    rescue => e
      e.class.name
    end

    debug_value = begin
      debug(Object.new)
    rescue => e
      e.class.name
    end

    p "Three months ago: #{three_months_value}"

    p "A million dollars: #{million_dollars_value}"

    p "debug: #{debug_value}"
  end
end
