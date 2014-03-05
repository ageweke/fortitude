module Fortitude
  class PartialTagPlaceholder
    class << self
      def instance
        @instance ||= new
      end
    end

    def name
      :_fortitude_partial_placeholder
    end

    def validate_can_enclose!(widget, tag_object)
      # nothing here, always OK
    end
  end
end
