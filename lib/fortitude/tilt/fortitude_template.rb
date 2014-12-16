require 'tilt'
require 'active_support/inflector'
require 'fortitude/rendering_context'
require 'fortitude/doctypes'

module Fortitude
  module Tilt
    class FortitudeTemplate < ::Tilt::Template
      def prepare
        ::Object.class_eval(data)

        # 2014-06-19 ageweke -- Earlier versions of Tilt try to instantiate the engine with an empty tempate as a way
        # of making sure it can be created, so we have to support this case.
        if data.strip.length > 0
          @fortitude_class = ::Fortitude::Widget.widget_class_from_source(
            data,
            :magic_comment_text => 'fortitude_tilt_class',
            :class_names_to_try => Array(options[:fortitude_class]) + Array(options[:class_names_to_try]))
        end
      end

      def render(scope=Object.new, locals = nil, &block)
        locals ||= { }

        rendering_context = Fortitude::RenderingContext.new({
          :yield_block => block, :render_yield_result => false,
          :helpers_object => scope, :instance_variables_object => scope })

        widget_assigns = { }

        scope.instance_variables.each do |instance_variable_name|
          if instance_variable_name.to_s =~ /^\@(.*)$/
            widget_assigns[$1] = scope.instance_variable_get(instance_variable_name)
          end
        end

        widget_assigns = widget_assigns.merge(locals)
        widget_assigns = fortitude_class.extract_needed_assigns_from(widget_assigns) unless fortitude_class.extra_assigns == :use

        widget = fortitude_class.new(widget_assigns)
        widget.render_to(rendering_context)
        rendering_context.output_buffer_holder.output_buffer
      end

      private
      attr_reader :fortitude_class
    end
  end
end
