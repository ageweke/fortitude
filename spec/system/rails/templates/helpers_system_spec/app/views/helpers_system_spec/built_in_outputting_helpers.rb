class Views::HelpersSystemSpec::BuiltInOutputtingHelpers < Fortitude::Widget
  def content
    # ActionView::Helpers::TextHelpers actually contains the only set of outputting helpers that
    # are built in to Rails...
    div(:class => "concat_container") do
      concat "this is concatted"
    end

    div(:class => "safe_concat_container") do
      concat "this is safe_concatted"
    end
  end
end
