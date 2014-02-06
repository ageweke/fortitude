require 'fortitude/tag'
require 'fortitude/errors'

module Fortitude
  class Widget
    class << self
      def tags_module
        @tags_module ||= begin
          out = Module.new
          include(out)
          out
        end
      end

      def tag(name, options = { })
        Fortitude::Tag.new(name, options).define_method_on!(tags_module)
      end

      def needs(*variables)
        @needs ||= [ ]
        @needs |= variables.map { |v| v.to_s.strip.downcase.to_sym }

        @needs.each do |n|
          class_eval <<-EOS
  def #{n}
    @_fortitude_assign_#{n}
  end
EOS
        end

        @needs
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

    def initialize(assigns = { })
      missing = [ ]

      self.class.needs.each do |n|
        if assigns.has_key?(n)
          instance_variable_set("@_fortitude_assign_#{n}", assigns[n])
        else
          missing << n
        end
      end

      if missing.length > 0
        raise Fortitude::Errors::MissingNeed.new(self, missing, assigns.keys)
      end
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
        @output.concat(AFTER_ATTRIBUTE_STRING)
        v.to_s.fortitude_append_escaped_string(@output)
        @output.concat(AFTER_VALUE_STRING)
      end
    end

    def to_html(rendering_context)
      @rendering_context = rendering_context
      @output = rendering_context.output
      content
    end

    def widget(w)
      w.to_html(@rendering_context)
    end

=begin
    def to_html(rendering_context)
      begin
        @rendering_context, old_rendering_context = rendering_context, @rendering_context
        @output = @rendering_context.output
        content
      ensure
        @rendering_context = old_rendering_context
      end
    end

    def widget(w)
      w.to_html(@rendering_context)
    end
=end
    def text(s)
      s.to_s.fortitude_append_escaped_string(@output)
    end

    def rawtext(s)
      @output.concat(s)
    end

    def shared_instance_variables
      @rendering_context.instance_variable_set
    end
  end
end
