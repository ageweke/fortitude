require 'fortitude/tag_support'
require 'fortitude/simple_template'

module Fortitude
  class Tag
    attr_reader :name, :spec
    attr_accessor :newline_before, :content_allowed, :allow_data_attributes, :allow_aria_attributes

    class << self
      def normalize_tag_name(name)
        name.to_s.strip.downcase.to_sym
      end
    end

    def initialize(name, options = { })
      options.assert_valid_keys(:valid_attributes, :newline_before, :content_allowed, :can_enclose,
        :allow_data_attributes, :allow_aria_attributes, :spec)

      @name = self.class.normalize_tag_name(name)

      self.valid_attributes = options[:valid_attributes]
      self.can_enclose = options[:can_enclose]
      @newline_before = !! options[:newline_before]
      @content_allowed = true unless options.has_key?(:content_allowed) && (! options[:content_allowed])
      @allow_data_attributes = true unless options.has_key?(:allow_data_attributes) && (! options[:allow_data_attributes])
      @allow_aria_attributes = true unless options.has_key?(:allow_aria_attributes) && (! options[:allow_aria_attributes])
      @spec = options[:spec]
    end

    def valid_attributes
      @allowable_attributes.keys if @allowable_attributes
    end

    def valid_attributes=(attributes)
      @allowable_attributes = to_symbol_hash(attributes)
    end

    def can_enclose
      @allowable_enclosed_elements.keys if @allowable_enclosed_elements
    end

    def can_enclose=(tags)
      @allowable_enclosed_elements = to_symbol_hash(tags)
      @allowable_enclosed_elements[:_fortitude_partial_placeholder] = true if @allowable_enclosed_elements
    end

    def dup
      self.class.new(name, {
        :valid_attributes => valid_attributes,
        :can_enclose => can_enclose,
        :content_allowed => content_allowed,
        :allow_data_attributes => allow_data_attributes,
        :allow_aria_attributes => allow_aria_attributes,
        :spec => spec
      })
    end

    CONCAT_METHOD = "original_concat"

    def validate_can_enclose!(widget, tag_object)
      return unless @allowable_enclosed_elements
      unless @allowable_enclosed_elements[tag_object.name]
        raise Fortitude::Errors::InvalidElementNesting.new(widget, name, tag_object.name)
      end
    end

    def validate_attributes(widget, attributes_hash)
      return unless @allowable_attributes
      disabled_sym = attributes_hash.delete(:_fortitude_skip_attribute_rule_enforcement)
      disabled_string = attributes_hash.delete('_fortitude_skip_attribute_rule_enforcement')
      return if disabled_sym || disabled_string
      return if widget.rendering_context.attribute_validation_disabled?
      bad = { }
      attributes_hash.each do |k, v|
        bad[k] = v unless is_valid_attribute?(k, v)
      end
      raise Fortitude::Errors::InvalidElementAttributes.new(self, name, bad, @allowable_attributes.keys) if bad.size > 0
    end

    def is_valid_attribute?(k, v)
      return true if @allowable_attributes.include?(k.to_sym)

      if @allow_data_attributes
        return true if k.to_s =~ /^data-\S/i || (k.to_s =~ /^data$/i && v.kind_of?(Hash))
      end

      if @allow_aria_attributes
        return true if k.to_s =~ /^aria-\S/i || (k.to_s =~ /^aria$/i && v.kind_of?(Hash))
      end

      return false
    end

    def validate_id_uniqueness(widget, attributes_hash)
      id = attributes_hash[:id] || attributes_hash['id']
      widget.rendering_context.validate_id_uniqueness(widget, name, id) if id
    end

    def define_method_on!(mod, options = {})
      options.assert_valid_keys(:enforce_element_nesting_rules, :enforce_attribute_rules, :enable_formatting, :enforce_id_uniqueness, :close_void_tags)

      unless mod.respond_to?(:fortitude_tag_support_included?) && mod.fortitude_tag_support_included?
        mod.send(:include, ::Fortitude::TagSupport)
      end

      alone_tag = if @content_allowed || options[:close_void_tags] then "<#{name}/>" else "<#{name}>" end

      ensure_constants(mod, :ALONE => alone_tag, :OPEN => "<#{name}>", :CLOSE => "</#{name}>",
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
        :needs_id_uniqueness => !! options[:enforce_id_uniqueness],
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
      map.each { |name, value| ensure_constant(target, tag_constant_name(name), value.freeze) }
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
