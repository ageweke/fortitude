class Views::Carryover::Show < Fortitude::Widgets::Html5
  needs :the_id

  def content
    h1 "Show Carryover #{the_id}"

    p "Edit: #{edit_carryover_path}"
  end
end
