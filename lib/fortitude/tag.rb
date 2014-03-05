require 'fortitude/tag_support'
require 'fortitude/simple_template'

module Fortitude
  class Tag
    attr_reader :name

    def initialize(name, options = { })
      options.assert_valid_keys(:valid_attributes, :newline_before, :content_allowed, :can_enclose)

      @name = name.to_s.strip.downcase.to_sym

      @valid_attributes = to_symbol_hash(options[:valid_attributes])
      @allowable_enclosed_elements = to_symbol_hash(options[:can_enclose])
      @allowable_enclosed_elements[:_fortitude_partial_placeholder] = true if @allowable_enclosed_elements
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

      ensure_constants(mod, :ALONE => "<#{name}/>", :OPEN => "<#{name}>", :CLOSE => "</#{name}>",
        :PARTIAL_OPEN => "<#{name}", :TAG_OBJECT => self)

      needs_formatting = !! options[:enable_formatting]

      if needs_formatting && @newline_before
        yield_call = "_fortitude_formatted_output_tag_yield(:#{name}) { yield }"
      elsif needs_formatting
        yield_call = "yield; rc.about_to_output_non_whitespace!"
      else
        yield_call = "yield"
      end

      text = Fortitude::SimpleTemplate.template('tag_method_template').result(
        :name => name.to_s, :yield_call => yield_call, :concat_method => CONCAT_METHOD,
        :needs_element_rules => !! options[:enforce_element_nesting_rules],
        :needs_attribute_rules => !! options[:enforce_attribute_rules],
        :needs_formatting => needs_formatting, :content_allowed => @content_allowed,
        :newline_before => @newline_before,
        :alone_const => tag_constant_name(:ALONE), :open_const => tag_constant_name(:OPEN),
        :close_const => tag_constant_name(:CLOSE), :partial_open_const => tag_constant_name(:PARTIAL_OPEN),
        :tag_object_const => tag_constant_name(:TAG_OBJECT), :partial_open_end_const => :FORTITUDE_TAG_PARTIAL_OPEN_END,
        :partial_open_alone_end_const => :FORTITUDE_TAG_PARTIAL_OPEN_ALONE_END)

      mod.module_eval(text)
    end

    private
    def tag_constant_name(key)
      "FORTITUDE_TAG_#{name.upcase}_#{key}".to_sym
    end

    def ensure_constants(target, map)
      map.each { |name, value| ensure_constant(target, tag_constant_name(name), value) }
    end

    def ensure_constant(target, const_name, const_value)
      target.send(:remove_const, const_name) if target.const_defined?(const_name)
      target.const_set(const_name, const_value.freeze)
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
