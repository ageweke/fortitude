module Fortitude
  class Widget
    module Caching
      extend ActiveSupport::Concern
      include ActionView::Helpers::CacheHelper

      module ClassMethods
        # PUBLIC API
        def cacheable(opts = {})
          if extra_assigns == :use
            extra_assigns :ignore
          end

          static_keys = opts.fetch(:key, [])
          options = opts.fetch(:options, {})

          define_method(:cache_contents) do |&block|
            cache calculate_cache_dependencies(assigns, static_keys), options do
              block.call
            end
          end

          around_content :cache_contents
        end
      end

      private

      def calculate_cache_dependencies(assigns, static_keys)
        (
          assigns.to_a.sort_by(&:first).flatten +
          static_keys +
          [widget_locale]
        )
      end
    end
  end
end
