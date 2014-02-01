class Views::DevelopmentModeSystemSpec::ReloadWidget < Fortitude::Widget
  def content
    p "Rails.env: #{Rails.env}"
    p "before_reload"
  end
end
