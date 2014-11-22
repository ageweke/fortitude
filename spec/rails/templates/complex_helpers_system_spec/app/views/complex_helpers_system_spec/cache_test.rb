class Views::ComplexHelpersSystemSpec::CacheTest < Fortitude::Widgets::Html5
  needs :a, :b

  def content
    text "before_cache(#{a},#{b})"
    cache(a) do
      text "inside_cache(#{a},#{b})"
    end
    text "after_cache(#{a},#{b})"
  end
end
