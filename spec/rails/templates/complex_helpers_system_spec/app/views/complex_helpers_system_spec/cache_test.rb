class Views::ComplexHelpersSystemSpec::CacheTest < Fortitude::Widget::Html5
  needs :a, :b

  def content
    text "before_cache(#{a},#{b})"
    # rawtext "fragment_name: #{cache_fragment_name(a)}"
    cache(a) do
      text "inside_cache(#{a},#{b})"
    end
    text "after_cache(#{a},#{b})"
  end
end
