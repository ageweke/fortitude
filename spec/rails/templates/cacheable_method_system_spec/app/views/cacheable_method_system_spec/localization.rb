class Views::CacheableMethodSystemSpec::Localization < Fortitude::Widgets::Html5
  cacheable

  def content
    text "hello is: #{t('.hello')} #{times_called}"
  end

  def times_called
    @@times_called ||= 0
    @@times_called += 1
  end
end
