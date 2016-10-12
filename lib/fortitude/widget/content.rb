require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module Content
      extend ActiveSupport::Concern

      module ClassMethods
        def inline_subclass(&block)
          out = Class.new(self)
          out.send(:define_method, :content, &block)
          out
        end

        def inline_html(assigns = { }, rendering_context = nil, &block)
          inline_subclass(&block).new(assigns).to_html(rendering_context)
        end

        # INTERNAL USE ONLY
        def rebuild_run_content!(why, klass = self)
          rebuilding(:run_content, why, klass) do
            acm = around_content_methods
            text = "def run_content(*args, &block)\n"
            text += "  out = nil\n"
            acm.each_with_index do |method_name, index|
              text += "  " + ("  " * index) + "#{method_name}(*args) do\n"
            end

            if use_localized_content_methods
              text += "  " + ("  " * acm.length) + "the_locale = widget_locale\n"
              text += "  " + ("  " * acm.length) + "locale_method_name = \"localized_content_\#{the_locale}\" if the_locale\n"
              text += "  " + ("  " * acm.length) + "out = if locale_method_name && respond_to?(locale_method_name)\n"
              text += "  " + ("  " * acm.length) + "  send(locale_method_name, *args, &block)\n"
              text += "  " + ("  " * acm.length) + "else\n"
              text += "  " + ("  " * acm.length) + "  content(*args, &block)\n"
              text += "  " + ("  " * acm.length) + "end\n"
            else
              text += "  " + ("  " * acm.length) + "out = content(*args, &block)\n"
            end

            (0..(acm.length - 1)).each do |index|
              text += "  " + ("  " * (acm.length - (index + 1))) + "end\n"
            end
            text += "  out\n"
            text += "rescue LocalJumpError => lje\n"
            text += "  raise Fortitude::Errors::NoBlockToYieldTo.new(self, lje)\n"
            text += "end"

            class_eval(text)

            direct_subclasses.each { |s| s.rebuild_run_content!(why, klass) }
          end
        end
      end

      # PUBLIC API
      def content
        raise "Must override in #{self.class.name}"
      end
    end
  end
end
