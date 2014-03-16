require 'fortitude/doctypes/base'

module Fortitude
  module Doctypes
    class Html5 < Base
      def initialize
        super(:html5, "html")
      end

      def default_javascript_tag_attributes
        { }
      end

      def needs_cdata_in_javascript_tag?
        false
      end

      tag :html, :newline_before => true
      tag :body, :newline_before => true
      tag :head, :newline_before => true
      tag :link, :newline_before => true, :content_allowed => false
      tag :style, :newline_before => true

      tag :header, :newline_before => true
      tag :nav, :newline_before => true
      tag :section, :newline_before => true
      tag :footer, :newline_before => true

      tag :script, :newline_before => true
      tag :meta, :newline_before => true, :content_allowed => false
      tag :title, :newline_before => true

      tag :h1, :newline_before => true
      tag :h2, :newline_before => true
      tag :h3, :newline_before => true
      tag :h4, :newline_before => true
      tag :h5, :newline_before => true
      tag :h6, :newline_before => true

      tag :div, :newline_before => true
      tag :span

      tag :ul, :newline_before => true
      tag :ol, :newline_before => true
      tag :li, :newline_before => true

      tag :p, :newline_before => true, :can_enclose => [ :b ], :valid_attributes => %w{class id}

      tag :a
      tag :img

      tag :form, :newline_before => true
      tag :input, :newline_before => true
      tag :submit, :newline_before => true
      tag :button, :newline_before => true
      tag :label, :newline_before => true
      tag :select, :newline_before => true
      tag :optgroup, :newline_before => true
      tag :option, :newline_before => true
      tag :textarea, :newline_before => true
      tag :fieldset, :newline_before => true

      tag :table, :newline_before => true
      tag :tr, :newline_before => true
      tag :th, :newline_before => true
      tag :td, :newline_before => true

      tag :time

      tag :i
      tag :b
      tag :em
      tag :strong

      tag :br, :content_allowed => false
      tag :hr, :newline_before => true, :content_allowed => false
    end
  end
end
