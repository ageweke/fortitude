require 'active_support'
require 'active_support/concern'

require 'fortitude/tags/tag_return_value'

module Fortitude
  module Tags
    module TagSupport
      extend ActiveSupport::Concern

      class TextPseudotag
        def name
          :_text
        end
      end

      FORTITUDE_TEXT_PSEUDOTAG = TextPseudotag.new

      FORTITUDE_TAG_PARTIAL_OPEN_END = ">".freeze

      def _fortitude_formatted_output_tag_yield(tag_name, suppress_formatting_inside)
        rc = @_fortitude_rendering_context
        if rc.format_output?
          rc.needs_newline!
          rc.increase_indent!
          begin
            rc.suppress_formatting! if suppress_formatting_inside
            yield
          ensure
            rc.decrease_indent!
            if suppress_formatting_inside
              rc.desuppress_formatting!
            else
              rc.needs_newline!
              rc.about_to_output_non_whitespace!
            end
          end
        else
          yield
        end
      end

      def _fortitude_raise_no_content_allowed_error(tag_name)
        raise Fortitude::Errors::NoContentAllowed.new(self, tag_name)
      end

      FORTITUDE_NO_RETURN_VALUE_FROM_TAGS = Fortitude::Tags::TagReturnValue.new

      module ClassMethods
        def fortitude_tag_support_included?
          true
        end
      end
    end
  end
end
