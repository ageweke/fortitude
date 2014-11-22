class Views::ComplexHelpersSystemSpec::CacheTagsTest < Fortitude::Widgets::Html5
  needs :a, :b

  format_output true

  def content
    p(:class => 'before_cache') do
      span "before_cache: a=#{a},b=#{b}"

      cache(a) do
        p(:class => "in_cache") do
          span "in_cache: a=#{a},b=#{b}"
        end
      end

      span("after_cache: a=#{a},b=#{b}")
    end

    p(:class => "after_cache_2") do
      span "after_cache_2: a=#{a},b=#{b}"
    end
  end
end
