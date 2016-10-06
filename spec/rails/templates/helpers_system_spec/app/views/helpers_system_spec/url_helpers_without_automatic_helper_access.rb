class Views::HelpersSystemSpec::UrlHelpersWithoutAutomaticHelperAccess < Fortitude::Widgets::Html5
  automatic_helper_access false

  def content
    root_path_value = begin
      root_path
    rescue => e
      e.class.name
    end

    foo_path_value = begin
      foo_path
    rescue => e
      e.class.name
    end

    foo_url_value = begin
      foo_url
    rescue => e
      e.class.name
    end

    foo_url_with_host_override_value = begin
      foo_url(:host => 'override.com')
    rescue => e
      e.class.name
    end

    p "Root Path: #{root_path_value}"

    p "Foo Path: #{foo_path_value}"

    p "Foo Url: #{foo_url_value}"

    p "Foo Url with host override: #{foo_url_with_host_override_value}"
  end
end
