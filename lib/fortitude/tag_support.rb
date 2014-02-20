require 'active_support/concern'

module Fortitude
  module TagSupport
    extend ActiveSupport::Concern

    FORTITUDE_TAG_PARTIAL_OPEN_END = ">".freeze
    FORTITUDE_TAG_PARTIAL_OPEN_ALONE_END = "/>".freeze

    def _fortitude_formatted_output_tag_yield(tag_name)
      rc = @_fortitude_rendering_context
      if rc.format_output?
        rc.needs_newline!
        rc.increase_indent!
        begin
          yield
        ensure
          rc.decrease_indent!
          rc.needs_newline!
          rc.about_to_output_non_whitespace!
        end
      else
        yield
      end
    end

    module ClassMethods
      def fortitude_tag_support_included?
        true
      end
    end
  end
end
