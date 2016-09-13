module ArbitraryName
  class CachedWidgetTwo < Fortitude::Widgets::Html5
    cacheable

    def content
      p "CachedWidgetTwo #{times_called}"
    end

    def times_called
      @@times_called ||= 0
      @@times_called += 1
    end
  end
end
