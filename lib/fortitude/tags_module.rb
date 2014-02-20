require 'fortitude/tag_support'

module Fortitude
  class TagsModule < Module
    def initialize(widget_class)
      include Fortitude::TagSupport

      @widget_class = widget_class
      @widget_class.send(:include, self)
    end
  end
end
