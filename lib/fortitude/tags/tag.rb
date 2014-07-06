require 'fortitude/tags/tag_support'
require 'fortitude/method_templates/simple_template'

# Note on handling tags that have no content inside them:
#
# - If the tag cannot ever have content inside it -- a "void tag" as denoted by HTML, specified here by
#   :content_allowed => false -- then we can either render it as "<tag>" (if :close_void_tags is set to false,
#   the default, on the widget class), or "<tag/>" (if :close_void_tags is set to true on the widget class).
# - If the tag can have content inside it, but this instance of it does not, then we always render it as
#   <tag></tag> (or <tag attr="value"...></tag>).
#
# Further, doctypes restrict the values you can set close_void_tags to on a widget: HTML5 allows either, HTML4
# requires it to be false, and XHTML requires it to be true.
#
# This is all per the information at:
#
# http://stackoverflow.com/questions/3558119/are-self-closing-tags-valid-in-html5
# http://www.w3.org/TR/xhtml-media-types/#C_2
# http://www.colorglare.com/2014/02/03/to-close-or-not-to-close.html
module Fortitude
  module Tags
    class Tag
      attr_reader :name, :spec
      attr_accessor :newline_before, :content_allowed, :allow_data_attributes, :allow_aria_attributes, :escape_direct_content

      class << self
        def normalize_tag_name(name)
          name.to_s.strip.downcase.to_sym
        end
      end

      def initialize(name, options = { })
        options.assert_valid_keys(:valid_attributes, :newline_before, :content_allowed, :can_enclose,
          :allow_data_attributes, :allow_aria_attributes, :spec, :escape_direct_content)

        @name = self.class.normalize_tag_name(name)

        self.valid_attributes = options[:valid_attributes]
        self.can_enclose = options[:can_enclose]
        @newline_before = !! options[:newline_before]
        @content_allowed = true unless options.has_key?(:content_allowed) && (! options[:content_allowed])
        @allow_data_attributes = true unless options.has_key?(:allow_data_attributes) && (! options[:allow_data_attributes])
        @allow_aria_attributes = true unless options.has_key?(:allow_aria_attributes) && (! options[:allow_aria_attributes])
        @escape_direct_content = true unless options.has_key?(:escape_direct_content) && (! options[:escape_direct_content])
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
          :escape_direct_content => escape_direct_content,
          :spec => spec
        })
      end

      CONCAT_METHOD = "original_concat"

      def validate_can_enclose!(widget, tag_object)
        return unless @allowable_enclosed_elements
        unless @allowable_enclosed_elements[tag_object.name]
          raise Fortitude::Errors::InvalidElementNesting.new(widget, self, tag_object)
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
        raise Fortitude::Errors::InvalidElementAttributes.new(widget, self, bad, @allowable_attributes.keys) if bad.size > 0
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
        options.assert_valid_keys(
          :record_emitting_tag, :enforce_attribute_rules, :enable_formatting,
          :enforce_id_uniqueness, :close_void_tags)

        unless mod.respond_to?(:fortitude_tag_support_included?) && mod.fortitude_tag_support_included?
          mod.send(:include, ::Fortitude::Tags::TagSupport)
        end

        if @content_allowed
          alone_tag = "<#{name}></#{name}>"
          partial_open_alone_end = "></#{name}>"
        elsif options[:close_void_tags]
          alone_tag = "<#{name}/>"
          partial_open_alone_end = "/>"
        else
          alone_tag = "<#{name}>"
          partial_open_alone_end = ">"
        end

        ensure_constants(mod, :ALONE => alone_tag, :OPEN => "<#{name}>", :CLOSE => "</#{name}>",
          :PARTIAL_OPEN => "<#{name}", :TAG_OBJECT => self, :PARTIAL_OPEN_ALONE_END => partial_open_alone_end)

        needs_formatting = !! options[:enable_formatting]

        if needs_formatting && @newline_before
          yield_call = "_fortitude_formatted_output_tag_yield(:#{name}) { yield }"
        elsif needs_formatting
          yield_call = "yield; rc.about_to_output_non_whitespace!"
        else
          yield_call = "yield"
        end

        text = Fortitude::MethodTemplates::SimpleTemplate.template('tag_method_template').result(
          :name => name.to_s, :method_name => "tag_#{name}".to_s, :yield_call => yield_call, :concat_method => CONCAT_METHOD,
          :record_emitting_tag => (!! options[:record_emitting_tag]),
          :needs_attribute_rules => !! options[:enforce_attribute_rules],
          :needs_id_uniqueness => !! options[:enforce_id_uniqueness],
          :needs_formatting => needs_formatting, :content_allowed => @content_allowed,
          :newline_before => @newline_before,
          :escape_direct_content => @escape_direct_content,
          :alone_const => tag_constant_name(:ALONE), :open_const => tag_constant_name(:OPEN),
          :close_const => tag_constant_name(:CLOSE), :partial_open_const => tag_constant_name(:PARTIAL_OPEN),
          :tag_object_const => tag_constant_name(:TAG_OBJECT), :partial_open_end_const => :FORTITUDE_TAG_PARTIAL_OPEN_END,
          :partial_open_alone_end_const => tag_constant_name(:PARTIAL_OPEN_ALONE_END))

        mod.module_eval(text)
        mod.alias_method(name, "tag_#{name}")
      end

      private
      def tag_constant_name(key)
        "FORTITUDE_TAG_#{name.to_s.upcase}_#{key}".to_sym
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
end
