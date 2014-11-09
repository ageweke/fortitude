require 'active_support/concern'

module Fortitude
  module Rails
    module RenderingMethods
      extend ActiveSupport::Concern

      included do
        alias_method_chain :render, :fortitude
      end

      def fortitude_rendering_context_for(delegate_object, yield_block)
        @_fortitude_rendering_contexts ||= { }
        @_fortitude_rendering_contexts[delegate_object.object_id] ||= create_fortitude_rendering_context(
          :delegate_object => delegate_object, :yield_block => yield_block)
      end

      def create_fortitude_rendering_context(options)
        ::Fortitude::RenderingContext.new(options)
      end

      # This is our support for render :widget. Although, originally, it looked like creating a new subclass
      # of ActionView::Template was going to be the correct thing to do here, it turns out it isn't: the entire
      # template system is predicated around the idea that you have a template, which is compiled to output
      # Ruby source code, and then that gets evaluated to actually generate output.
      #
      # Because <tt>render :widget => ...</tt> takes an already-instantiated widget as input, this simply isn't
      # possible: you can't reverse-engineer an arbitrary Ruby object into source code, and, without source code,
      # the whole templating paradigm doesn't make sense.
      #
      # So, instead, we simply transform <tt>render :widget => ...</tt> into a <tt>render :text => ...</tt> of the
      # widget's output, and let Rails take it away from there.
      def render_with_fortitude(*args, &block)
        if (options = args[0]).kind_of?(Hash)
          if (widget = options[:widget])
            rendering_context = fortitude_rendering_context_for(self, nil)
            widget.render_to(rendering_context)

            options = options.dup
            options[:text] = rendering_context.output_buffer_holder.output_buffer.html_safe
            options[:layout] = true unless options.has_key?(:layout)

            new_args = [ options ] + args[1..-1]
            return render_without_fortitude(*new_args, &block)
          elsif (widget_block = options[:inline]) && (options[:type] == :fortitude)
            options.delete(:inline)

            rendering_context = fortitude_rendering_context_for(self, nil)
            widget_class = Class.new(Fortitude::Widgets::Html5)
            widget_class.use_instance_variables_for_assigns(true)
            widget_class.extra_assigns(:use)
            widget_class.send(:define_method, :content, &widget_block)

            assigns = { }
            instance_variables.each do |ivar_name|
              value = instance_variable_get(ivar_name)
              assigns[$1.to_sym] = value if ivar_name =~ /^@(.*)$/
            end
            assigns = assigns.merge(options[:locals] || { })

            widget = widget_class.new(assigns)
            widget.render_to(rendering_context)

            options = options.dup
            options[:text] = rendering_context.output_buffer_holder.output_buffer.html_safe
            options[:layout] = true unless options.has_key?(:layout)

            new_args = [ options ] + args[1..-1]
            return render_without_fortitude(*new_args, &block)
          end
        end

        return render_without_fortitude(*args, &block)
      end
    end
  end
end
