require 'fortitude/tag_support'

module Fortitude
  class Tag
    attr_reader :name

    def initialize(name, options = { })
      @name = name.to_s.strip.downcase.to_sym
      @options = options

      @valid_attributes = nil
      if @options[:valid_attributes]
        @valid_attributes = { }
        @options[:valid_attributes].each { |a| @valid_attributes[a.to_s.strip.to_sym] = true }
      end

      # @options.assert_valid_keys([ ])
    end

    CONCAT_METHOD = "original_concat"

    def validate_can_enclose!(widget, tag_object)
      return unless @options[:can_enclose]
      unless @options[:can_enclose].include?(tag_object.name)
        raise Fortitude::Errors::InvalidElementNesting.new(widget, name, tag_object.name)
      end
    end

    def validate_attributes(widget, attributes_hash)
      return unless @valid_attributes
      bad = { }
      attributes_hash.each do |k, v|
        bad[k] = v unless @valid_attributes.include?(k.to_sym)
      end
      raise Fortitude::Errors::InvalidElementAttributes.new(self, name, bad, @valid_attributes.keys) if bad.size > 0
    end

    def define_method_on!(mod, options = { })
      unless mod.respond_to?(:fortitude_tag_support_included?) && mod.fortitude_tag_support_included?
        mod.send(:include, ::Fortitude::TagSupport)
      end

      define_constant_string(mod, :ALONE, "<#{name}/>")
      define_constant_string(mod, :OPEN, "<#{name}>")
      define_constant_string(mod, :CLOSE, "</#{name}>")
      define_constant_string(mod, :PARTIAL_OPEN, "<#{name}")

      validate_attributes = if options[:enforce_attribute_rules]
        "this_tag.validate_attributes(self, PARAM)"
      else
        ""
      end

      method_text = <<-EOS
      def #{name}(content_or_attributes = nil, attributes = nil)
        o = @_fortitude_output_buffer_holder.output_buffer

EOS

      if options[:enforce_element_nesting_rules] || options[:enforce_attribute_rules]
        method_text << <<-EOS
        this_tag = self.class.get_tag(:#{name})
EOS
      end

      if options[:enforce_element_nesting_rules]
        method_text << <<-EOS
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
          #{validate_attributes.gsub('PARAM', 'content_or_attributes')}
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
          #{validate_attributes.gsub('PARAM', 'attributes')}
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
