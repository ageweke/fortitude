require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module StartAndEndComments
      extend ActiveSupport::Concern

      # INTERNAL USE ONLY
      def widget_nesting_depth
        @_fortitude_widget_nesting_depth ||= @_fortitude_rendering_context.current_widget_depth
      end
      private :widget_nesting_depth

      MAX_START_COMMENT_VALUE_STRING_LENGTH = 100
      START_COMMENT_VALUE_STRING_TOO_LONG_ELLIPSIS = "...".freeze
      MAX_ASSIGNS_LENGTH_BEFORE_MULTIPLE_LINES = 200
      START_COMMENT_EXTRA_INDENT_FOR_NEXT_LINE = " " * 5

      # INTERNAL USE ONLY
      def start_and_end_comments
        if self.class.start_and_end_comments
          fo = self.class.format_output

          comment_text = "BEGIN #{self.class.name || '(anonymous widget class)'} depth #{widget_nesting_depth}"

          assign_keys = assigns.keys
          if assign_keys.length > 0

            assign_text = assign_keys.map do |assign|
              value = assigns[assign]
              out = ":#{assign} => "
              out << "(DEFAULT) " if assigns.is_default?(assign)

              value_string = if value.respond_to?(:to_fortitude_comment_string) then value.to_fortitude_comment_string else value.inspect end
              if value_string.length > MAX_START_COMMENT_VALUE_STRING_LENGTH
                value_string = value_string[0..(MAX_START_COMMENT_VALUE_STRING_LENGTH - START_COMMENT_VALUE_STRING_TOO_LONG_ELLIPSIS.length)] + START_COMMENT_VALUE_STRING_TOO_LONG_ELLIPSIS
              end
              out << value_string
              out
            end

            total_length = assign_text.map(&:length).inject(0, &:+)
            if total_length > MAX_ASSIGNS_LENGTH_BEFORE_MULTIPLE_LINES
              newline_and_indent = "\n#{@_fortitude_rendering_context.current_indent}"
              newline_and_extra_indent = newline_and_indent + START_COMMENT_EXTRA_INDENT_FOR_NEXT_LINE

              comment_text << ":"
              assign_text.each do |at|
                comment_text << newline_and_extra_indent
                comment_text << at
              end
              comment_text << newline_and_indent
            else
              comment_text << ": "
              comment_text << assign_text.join(", ")
            end
          end
          tag_comment comment_text
          yield
          tag_comment "END #{self.class.name} depth #{widget_nesting_depth}"
        else
          yield
        end
      end
      private :start_and_end_comments
    end
  end
end
