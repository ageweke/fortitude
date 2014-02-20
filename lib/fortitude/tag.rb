require 'fortitude/tag_support'

module Fortitude
  class Tag
    attr_reader :name

    def initialize(name, options = { })
      @name = name.to_s.strip.downcase.to_sym
      @options = options

      # @options.assert_valid_keys([ ])
    end

    CONCAT_METHOD = "original_concat"

    def validate_can_enclose!(widget, tag_object)
      return unless @options[:can_enclose]
      unless @options[:can_enclose].include?(tag_object.name)
        raise Fortitude::Errors::InvalidElementNesting.new(widget, tag_object.name, name)
      end
    end

    def define_method_on!(mod, options = { })
      unless mod.respond_to?(:fortitude_tag_support_included?) && mod.fortitude_tag_support_included?
        mod.send(:include, ::Fortitude::TagSupport)

        mod.module_eval do
    def _fortitude_formatted_output_tag_yield(tag_name)
      rc = @_fortitude_rendering_context
      if rc.format_output?
        rc.needs_newline!
        rc.increase_indent!
        begin
          yield
        ensure
          rc.decrease_indent!
          rc.needs_newline!
          rc.about_to_output_non_whitespace!
        end
      else
        yield
      end
    end
        end
      end

      define_constant_string(mod, :ALONE, "<#{name}/>")
      define_constant_string(mod, :OPEN, "<#{name}>")
      define_constant_string(mod, :CLOSE, "</#{name}>")
      define_constant_string(mod, :PARTIAL_OPEN, "<#{name}")

      # options[:enable_formatting] = true

      method_text = <<-EOS
      def #{name}(content_or_attributes = nil, attributes = nil)
        o = @_fortitude_output_buffer_holder.output_buffer

EOS

      if options[:enforce_element_nesting_rules]
        method_text << <<-EOS
        this_tag = self.class.get_tag(:#{name})
        @_fortitude_rendering_context.start_element_for_rules(self, this_tag)
      begin
EOS
      end

      do_yield = "yield"

      if options[:enable_formatting]
        method_text << <<-EOS
        rc = @_fortitude_rendering_context
        format_output = rc.format_output?
EOS

        if @options[:newline_before]
          method_text << <<-EOS
        if format_output
          rc.needs_newline!
        end
EOS
          do_yield = %{_fortitude_formatted_output_tag_yield(#{name.inspect}) { yield }}
        else
          do_yield = %{yield; rc.about_to_output_non_whitespace!}
        end

        method_text << <<-EOS
        rc.about_to_output_non_whitespace! if format_output
EOS
      end

      method_text << <<-EOS
        if (! content_or_attributes)
          if block_given?
            o.#{CONCAT_METHOD}(#{string_const_name(:OPEN)})
            #{do_yield}
            o.#{CONCAT_METHOD}(#{string_const_name(:CLOSE)})
          else
            o.#{CONCAT_METHOD}(#{string_const_name(:ALONE)})
          end
        elsif content_or_attributes.kind_of?(Hash)
          o.#{CONCAT_METHOD}(#{string_const_name(:PARTIAL_OPEN)})
          content_or_attributes.fortitude_append_as_attributes(o, nil)

          if block_given?
            o.#{CONCAT_METHOD}(FORTITUDE_TAG_PARTIAL_OPEN_END)
            #{do_yield}
            o.#{CONCAT_METHOD}(#{string_const_name(:CLOSE)})
          else
            o.#{CONCAT_METHOD}(FORTITUDE_TAG_PARTIAL_OPEN_ALONE_END)
          end
        elsif (! attributes)
          o.#{CONCAT_METHOD}(#{string_const_name(:OPEN)})
          content_or_attributes.to_s.fortitude_append_escaped_string(o)
          if block_given?
            #{do_yield}
          end
          o.#{CONCAT_METHOD}(#{string_const_name(:CLOSE)})
        else
          o.#{CONCAT_METHOD}(#{string_const_name(:PARTIAL_OPEN)})
          attributes.fortitude_append_as_attributes(o, nil)
          o.#{CONCAT_METHOD}(FORTITUDE_TAG_PARTIAL_OPEN_END)

          content_or_attributes.to_s.fortitude_append_escaped_string(o)
          if block_given?
            #{do_yield}
          end
          o.#{CONCAT_METHOD}(#{string_const_name(:CLOSE)})
        end
EOS

      if options[:enable_formatting] && @options[:newline_before]
        method_text << <<-EOS
        rc.needs_newline! if format_output
EOS
      end

      if options[:enforce_element_nesting_rules]
        method_text << <<-EOS
      ensure
        @_fortitude_rendering_context.end_element_for_rules(self, this_tag)
      end
EOS
      end

      method_text << <<-EOS
      end
EOS

      mod.module_eval(method_text)
    end

    private
    def string_const_name(key)
      "FORTITUDE_TAG_#{name.upcase}_#{key}".to_sym
    end

    def define_constant_string(target_module, key, value)
      const_name = string_const_name(key)
      target_module.send(:remove_const, const_name) if target_module.const_defined?(const_name)
      target_module.const_set(const_name, value.freeze)
    end
  end
end
