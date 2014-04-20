require 'tilt'
require 'active_support/inflector'

module Fortitude
  module Tilt
    class FortitudeTemplate < ::Tilt::Template
      def initialize(*args)
        super(*args)
      end

      def prepare
        evaluate_template!

        @fortitude_class = first_class_that_is_a_widget_class(all_possible_class_names)
        unless @fortitude_class
          raise %{Due to the way Tilt is designed, Fortitude unfortunately has to guess, given a template,
what the actual class name of the widget it contains is. Despite our best efforts, we were unable to
guess what the name of the class involved is.

Given the source of the template, we tried the following class names:

#{all_possible_class_names.join("\n")}

You can correct this problem either by passing a :fortitude_class option to Tilt, giving
either the name of the widget class or the actual widget Class object, or by adding a
comment to the source of the template, like so:

#!fortitude_tilt_class: Foo::Bar::MyWidget}
        end
      end

      def render(scope=Object.new, locals={}, &block)
        rendering_context = Fortitude::RenderingContext.new({ :yield_block => block, :render_yield_result => false })

        widget_assigns = { }.with_indifferent_access

        scope.instance_variables.each do |instance_variable_name|
          if instance_variable_name.to_s =~ /^\@(.*)$/
            widget_assigns[$1] = scope.instance_variable_get(instance_variable_name)
          end
        end

        widget_assigns = widget_assigns.merge(locals)
        widget_assigns = @fortitude_class.extract_needed_assigns_from(widget_assigns) unless @fortitude_class.extra_assigns == :use

        widget = @fortitude_class.new(widget_assigns)
        widget.to_html(rendering_context)
        rendering_context.output_buffer_holder.output_buffer
      end

      private
      def explicit_fortitude_class
        explicit_fortitude_class_from_option || explicit_fortitude_class_from_comment
      end

      def explicit_fortitude_class_from_option
        nil
      end

      def explicit_fortitude_class_from_comment
        nil
      end

      def all_possible_class_names
        out = [ ]
        module_nesting = [ ]

        data.scan(/\bmodule\s+(\S+)/) do |module_name|
          module_nesting << module_name
        end

        data.scan(/\bclass\s+(\S+)/) do |(class_name)|
          out << class_name
        end

        out.uniq!

        while module_nesting.length > 0
          possible_module_name = module_nesting.join("::")
          out.reverse.each do |class_name|
            out.unshift("#{possible_module_name}::#{class_name}")
          end
          module_nesting.pop
        end

        out
      end

      def first_class_that_is_a_widget_class(class_names)
        class_names.each do |class_name|
          begin
            klass = "::#{class_name}".constantize
            return klass if is_widget_class?(klass)
          rescue NameError => ne
            # ok, keep going
          end
        end

        nil
      end

      def evaluate_template!
        ::Object.class_eval(data)
      end

      def is_widget_class?(klass)
        if (! klass)
          false
        elsif (! klass.kind_of?(Class))
          false
        elsif klass == ::BasicObject
          false
        elsif klass == ::Fortitude::Widget::Base
          true
        else
          is_widget_class?(klass.superclass)
        end
      end
    end
  end
end
