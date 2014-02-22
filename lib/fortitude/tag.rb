require 'fortitude/tag_support'

module Fortitude
  class Tag
    class << self
      def template_text_lines
        @template_text_lines ||= File.read(File.join(File.dirname(__FILE__), 'tag_method_template.rb.smpl')).split(/\r\n|\r|\n/)
      end
    end

    attr_reader :name

    def initialize(name, options = { })
      options.assert_valid_keys(:valid_attributes, :newline_before, :content_allowed, :can_enclose)

      @name = name.to_s.strip.downcase.to_sym

      @valid_attributes = to_symbol_hash(options[:valid_attributes])
      @allowable_enclosed_elements = to_symbol_hash(options[:can_enclose])
      @newline_before = !! options[:newline_before]
      @content_allowed = true unless options.has_key?(:content_allowed) && (! options[:content_allowed])
    end

    CONCAT_METHOD = "original_concat"

    def validate_can_enclose!(widget, tag_object)
      return unless @allowable_enclosed_elements
      unless @allowable_enclosed_elements[tag_object.name]
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

    def define_method_on!(mod, options = {})
      options.assert_valid_keys(:enforce_element_nesting_rules, :enforce_attribute_rules, :enable_formatting)

      unless mod.respond_to?(:fortitude_tag_support_included?) && mod.fortitude_tag_support_included?
        mod.send(:include, ::Fortitude::TagSupport)
      end

      define_constant_string(mod, :ALONE, "<#{name}/>")
      define_constant_string(mod, :OPEN, "<#{name}>")
      define_constant_string(mod, :CLOSE, "</#{name}>")
      define_constant_string(mod, :PARTIAL_OPEN, "<#{name}")

      const_set_or_replace(mod, "TAG_OBJECT_#{ucname}", self)

      needs_element_rules = !! options[:enforce_element_nesting_rules]
      needs_attribute_rules = !! options[:enforce_attribute_rules]
      needs_formatting = !! options[:enable_formatting]
      content_allowed = @content_allowed
      newline_before = @newline_before
      needs_tag = needs_element_rules || needs_attribute_rules
      needs_rendering_context = needs_element_rules || needs_formatting

      if needs_formatting && newline_before
        yield_call = "_fortitude_formatted_output_tag_yield(:#{name}) { yield }"
      elsif needs_formatting
        yield_call = "yield; rc.about_to_output_non_whitespace!"
      else
        yield_call = "yield"
      end

      substitutions = { 'name' => name.to_s, 'ucname' => ucname, 'yield_call' => yield_call, 'concat_method' => CONCAT_METHOD }

      lines = [ ]
      self.class.template_text_lines.each do |l|
        if l =~ /^(.*)\#\s*\:if\s*(.*?)\s*$/i
          l, condition = $1, $2
          next unless eval(condition)
        end

        substitutions.each { |k,v| l = l.gsub("\#{#{k}}", v) }
        lines << l
      end

      text = lines.join("\n")
      mod.module_eval(text)
    end

    private
    def ucname
      name.to_s.upcase
    end

    def string_const_name(key)
      "FORTITUDE_TAG_#{name.upcase}_#{key}".to_sym
    end

    def const_set_or_replace(target, const_name, const_value)
      target.send(:remove_const, const_name) if target.const_defined?(const_name)
      target.const_set(const_name, const_value.freeze)
    end

    def define_constant_string(target_module, key, value)
      const_name = string_const_name(key)
      const_set_or_replace(target_module, const_name, value)
    end

    def to_symbol_hash(array)
      if array
        out = { }
        array.each { |a| out[a.to_s.strip.to_sym] = true }
        out
      end
    end
  end
end
