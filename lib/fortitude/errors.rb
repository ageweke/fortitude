module Fortitude
  module Errors
    class Base < StandardError; end

    class MissingNeed < Base
      attr_reader :widget, :missing_needs, :supplied_variables

      def initialize(widget, missing_needs, supplied_variables)
        super(%{The widget #{widget.class.name} requires the following parameters to render, but they were not supplied: #{missing_needs.sort_by(&:to_s).join(", ")}})
        @widget = widget
        @missing_needs = missing_needs
        @supplied_variables = supplied_variables
      end
    end
  end
end
