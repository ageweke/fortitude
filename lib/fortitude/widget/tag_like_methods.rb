require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module TagLikeMethods
      extend ActiveSupport::Concern

      # From http://www.w3.org/TR/html5/syntax.html#comments:
      #
      # Comments must start with the four character sequence U+003C LESS-THAN SIGN, U+0021 EXCLAMATION MARK,
      # U+002D HYPHEN-MINUS, U+002D HYPHEN-MINUS (<!--). Following this sequence, the comment may have text,
      # with the additional restriction that the text must not start with a single ">" (U+003E) character,
      # nor start with a U+002D HYPHEN-MINUS character (-) followed by a ">" (U+003E) character, nor contain
      # two consecutive U+002D HYPHEN-MINUS characters (--), nor end with a U+002D HYPHEN-MINUS character (-).
      # Finally, the comment must be ended by the three character sequence U+002D HYPHEN-MINUS, U+002D HYPHEN-MINUS,
      # U+003E GREATER-THAN SIGN (-->).

      # INTERNAL USE ONLY
      def comment_escape(string)
        string = "_#{string}" if string =~ /^\s*(>|->)/
        string = string.gsub("--", "- - ") if string =~ /\-\-/ # don't gsub if it doesn't match to avoid generating garbage
        string = "#{string}_" if string =~ /\-\s*$/i
        string
      end
      private :comment_escape

      # PUBLIC API
      def tag_comment(s)
        fo = self.class.format_output
        @_fortitude_rendering_context.needs_newline! if fo
        raise ArgumentError, "You cannot pass a block to a comment" if block_given?
        tag_rawtext "<!-- "
        tag_rawtext comment_escape(s)
        tag_rawtext " -->"
        @_fortitude_rendering_context.needs_newline! if fo
      end

      # PUBLIC API
      def tag_javascript(content = nil, &block)
        args = if content.kind_of?(Hash)
          [ self.class.doctype.default_javascript_tag_attributes.merge(content) ]
        elsif content
          if block
            raise ArgumentError, "You can't supply JavaScript content both via text and a block"
          else
            block = lambda { tag_rawtext content }
            [ self.class.doctype.default_javascript_tag_attributes.dup ]
          end
        else
          [ self.class.doctype.default_javascript_tag_attributes.dup ]
        end

        actual_block = block
        if self.class.doctype.needs_cdata_in_javascript_tag?
          actual_block = lambda do
            tag_rawtext "\n//#{CDATA_START}\n"
            block.call
            tag_rawtext "\n//#{CDATA_END}\n"
          end
        end

        @_fortitude_rendering_context.with_indenting_disabled do
          script(*args, &actual_block)
        end
      end

      %w{comment javascript}.each do |non_tag_method|
        alias_method non_tag_method, "tag_#{non_tag_method}"
      end

      CDATA_START = "<![CDATA[".freeze
      CDATA_END = "]]>".freeze

      # PUBLIC API
      def cdata(s = nil, &block)
        if s
          raise ArgumentError, "You can only pass literal text or a block, not both" if block

          components = s.split("]]>")

          if components.length > 1
            components.each_with_index do |s, i|
              this_component = s
              this_component = ">#{this_component}" if i > 0
              this_component = "#{this_component}]]" if i < (components.length - 1)
              cdata(this_component)
            end
          else
            tag_rawtext CDATA_START
            tag_rawtext s
            tag_rawtext CDATA_END
          end
        else
          tag_rawtext CDATA_START
          yield
          tag_rawtext CDATA_END
        end
      end
    end
  end
end
