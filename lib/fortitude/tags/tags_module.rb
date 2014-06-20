require 'fortitude/tags/tag_support'

module Fortitude
  module Tags
    class TagsModule < Module
      def initialize(widget_class)
        include Fortitude::Tags::TagSupport

        @widget_class = widget_class
        @widget_class.send(:include, self)
      end

      public :alias_method
    end
  end
end
