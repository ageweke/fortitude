class Views::HelpersSystemSpec::BasicHelpers < Fortitude::Widgets::Html5
  def content
    three_months_ago = 3.months.ago
    p "Three months ago: #{distance_of_time_in_words_to_now(three_months_ago)}"

    p "A million dollars: #{number_to_currency(1_000_000.00)}"

    p do
      text "Select datetime:"
      text select_datetime(1.year.ago)
    end
  end
end
