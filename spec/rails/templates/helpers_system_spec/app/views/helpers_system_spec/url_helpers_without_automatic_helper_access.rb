class Views::HelpersSystemSpec::UrlHelpersWithoutAutomaticHelperAccess < Fortitude::Widgets::Html5
  automatic_helper_access false

  def content
    excitedly_value = begin
      excitedly("great")
    rescue => e
      e.class.name
    end

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

    p "Excitedly: #{excitedly_value}"

    p "Root Path: #{root_path_value}"

    p "Foo Path: #{foo_path_value}"

    p "Foo Url: #{foo_url_value}"

    p "Foo Url with host override: #{foo_url_with_host_override_value}"
  end
end
