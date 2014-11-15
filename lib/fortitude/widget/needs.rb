require 'active_support'
require 'active_support/concern'

require 'fortitude/method_templates/simple_template'
require 'fortitude/support/assigns_proxy'

module Fortitude
  class Widget
    module Needs
      extend ActiveSupport::Concern

      # INTERNAL USE ONLY
      REQUIRED_NEED = Object.new
      # INTERNAL USE ONLY
      NOT_PRESENT_NEED = Object.new

      # INTERNAL USE ONLY
      included do
        attr_reader :_fortitude_default_assigns
      end

      module ClassMethods
        # PUBLIC API
        def needs(*names)
          previous_needs = needs_as_hash
          return previous_needs if names.length == 0

          @this_class_needs ||= { }

          with_defaults_raw = { }
          with_defaults_raw = names.pop if names[-1] && names[-1].kind_of?(Hash)

          names = names.map { |n| n.to_s.strip.downcase.to_sym }
          with_defaults = { }
          with_defaults_raw.each { |k,v| with_defaults[k.to_s.strip.downcase.to_sym] = v }

          bad_names = names.select { |n| ! is_valid_ruby_method_name?(n.to_s) }
          raise ArgumentError, "Needs in a Fortitude widget class must be valid Ruby method names; these are not: #{bad_names.inspect}" if bad_names.length > 0

          names.each do |name|
            @this_class_needs[name] = REQUIRED_NEED
          end

          with_defaults.each do |name, default_value|
            @this_class_needs[name] = default_value.freeze
          end

          rebuild_needs!(:need_declared)

          needs_as_hash
        end

        # INTERNAL USE ONLY
        def is_valid_ruby_method_name?(s)
          s.to_s =~ /^[A-Za-z_][A-Za-z0-9_]*[\?\!]?$/
        end

        # INTERNAL USE ONLY
        def needs_as_hash
          @_fortitude_needs_as_hash ||= begin
            out = { }
            out = superclass.needs_as_hash if superclass.respond_to?(:needs_as_hash)
            out.merge(@this_class_needs || { })
          end
        end

        # INTERNAL USE ONLY
        def rebuild_needs!(why, klass = self)
          rebuilding(:needs, why, klass) do
            @_fortitude_needs_as_hash = nil
            mark_my_needs_methods_as_stale!
            direct_subclasses.each { |s| s.rebuild_needs!(why, klass) }
          end
        end

        # PUBLIC API
        def extract_needed_assigns_from(input)
          input = input.with_indifferent_access

          out = { }
          needs_as_hash.keys.each do |name|
            out[name] = input[name] if input.has_key?(name)
          end
          out
        end

        # INTERNAL USE ONLY
        STANDARD_INSTANCE_VARIABLE_PREFIX = "_fortitude_assign_"

        # INTERNAL USE ONLY
        def instance_variable_name_for_need(need_name)
          effective_name = need_name.to_s
          effective_name.gsub!("!", "_fortitude_bang")
          effective_name.gsub!("?", "_fortitude_question")
          "@" + (use_instance_variables_for_assigns ? "" : STANDARD_INSTANCE_VARIABLE_PREFIX) + effective_name
        end

        # INTERNAL USE ONLY
        def mark_my_needs_methods_as_stale!
          @_fortitude_my_needs_methods_up_to_date = false
        end

        def ensure_needs_methods_are_up_to_date!
          out = false
          out ||= superclass.ensure_needs_methods_are_up_to_date! if superclass.respond_to?(:ensure_needs_methods_are_up_to_date!)

          unless @_fortitude_my_needs_methods_up_to_date
            rebuild_my_needs_methods!
            @_fortitude_my_needs_methods_up_to_date = true
            out = true
          end

          out
        end

        def rebuild_my_needs_methods!
          n = needs_as_hash

          needs_text = n.map do |need, default_value|
            Fortitude::MethodTemplates::SimpleTemplate.template('need_assignment_template').result(:extra_assigns => extra_assigns,
              :need => need, :has_default => (default_value != REQUIRED_NEED),
              :ivar_name => instance_variable_name_for_need(need)
            )
          end.join("\n\n")

          assign_locals_from_text = Fortitude::MethodTemplates::SimpleTemplate.template('assign_locals_from_template').result(
            :extra_assigns => extra_assigns, :needs_text => needs_text)
          class_eval(assign_locals_from_text)

          n.each do |need, default_value|
            text = Fortitude::MethodTemplates::SimpleTemplate.template('need_method_template').result(
              :need => need, :ivar_name => instance_variable_name_for_need(need),
              :debug => self.debug)
            needs_module.module_eval(text)
          end
        end

        private :rebuild_my_needs_methods!
      end

      def assign_locals_from(assigns)
        self.class.ensure_needs_methods_are_up_to_date!
        assign_locals_from(assigns)
      end

      # PUBLIC API
      def shared_variables
        @_fortitude_rendering_context.instance_variable_set
      end

      # INTERNAL USE ONLY
      def instance_variable_name_for_need(need)
        self.class.instance_variable_name_for_need(need)
      end

      # INTERNAL USE ONLY
      def needs_as_hash
        @_fortitude_needs_as_hash ||= self.class.needs_as_hash
      end

      # PUBLIC API
      def assigns
        @_fortitude_assigns_proxy ||= begin
          keys = needs_as_hash.keys
          keys |= (@_fortitude_raw_assigns.keys.map(&:to_sym)) if self.class.extra_assigns == :use

          Fortitude::Support::AssignsProxy.new(self, keys)
        end
      end

      # INTERNAL USE ONLY
      def widget_extra_assigns
        (@_fortitude_extra_assigns || { })
      end

      # INTERNAL USE ONLY
      def transfer_shared_variables(*args, &block)
        if self.class.implicit_shared_variable_access
          @_fortitude_rendering_context.instance_variable_set.with_instance_variable_copying(self, *args, &block)
        else
          block.call(*args)
        end
      end
      private :transfer_shared_variables
    end
  end
end
