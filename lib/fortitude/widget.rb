require 'fortitude/tag'

module Fortitude
  class Widget
    class << self
      def tag(name, options = { })
        Fortitude::Tag.new(name, options).define_method_on!(self)
      end
    end

    tag :html
    tag :body
    tag :head
    tag :link
    tag :style

    tag :header
    tag :nav
    tag :section
    tag :footer

    tag :script
    tag :meta
    tag :title

    tag :h1
    tag :h2
    tag :h3
    tag :h4
    tag :h5
    tag :h6

    tag :div
    tag :span

    tag :ul
    tag :ol
    tag :li

    tag :p

    tag :a
    tag :img

    tag :form
    tag :input
    tag :submit
    tag :button
    tag :label
    tag :select
    tag :optgroup
    tag :option
    tag :textarea
    tag :fieldset

    tag :table
    tag :tr
    tag :th
    tag :td

    tag :time

    tag :i
    tag :b
    tag :em
    tag :strong

    tag :br
    tag :hr

    def initialize(assigns)
      @assigns = assigns
    end

    def content
      raise "Must override in #{self.class.name}"
    end

    BEFORE_ATTRIBUTE_STRING = " ".freeze
    AFTER_ATTRIBUTE_STRING = "=\"".freeze
    AFTER_VALUE_STRING = "\"".freeze

    def _attributes(h)
      h.each do |k,v|
        @output.concat(BEFORE_ATTRIBUTE_STRING)
        k.to_s.fortitude_append_escaped_string(@output)
        # @output << ERB::Util.h(k)
        @output.concat(AFTER_ATTRIBUTE_STRING)
        v.to_s.fortitude_append_escaped_string(@output)
        # @output << ERB::Util.h(v)
        @output.concat(AFTER_VALUE_STRING)
      end
    end

    def to_html(output)
      @output = output
      content
    end

    def text(s)
      # @output << ERB::Util.h(s)
      s.fortitude_append_escaped_string(@output)
    end

    def rawtext(s)
      @output << s
    end
  end
end
