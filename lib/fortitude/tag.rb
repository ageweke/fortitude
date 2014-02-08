require 'fortitude/tag_support'

module Fortitude
  class Tag
    attr_reader :name

    def initialize(name, options = { })
      @name = name.to_s.strip.downcase.to_sym
      @options = options

      # @options.assert_valid_keys([ ])
    end

    CONCAT_METHOD = "concat"

    def define_method_on!(mod)
      mod.send(:include, ::Fortitude::TagSupport) unless mod.respond_to?(:fortitude_tag_support_included?) && mod.fortitude_tag_support_included?

      define_constant_string(mod, :ALONE, "<#{name}/>")
      define_constant_string(mod, :OPEN, "<#{name}>")
      define_constant_string(mod, :CLOSE, "</#{name}>")
      define_constant_string(mod, :PARTIAL_OPEN, "<#{name}")

      mod.module_eval <<-EOS
      def #{name}(attributes = nil)
        o = @_fortitude_output

        if (! attributes)
          if block_given?
            o.#{CONCAT_METHOD}(#{string_const_name(:OPEN)})
            yield
            o.#{CONCAT_METHOD}(#{string_const_name(:CLOSE)})
          else
            o.#{CONCAT_METHOD}(#{string_const_name(:ALONE)})
          end
        elsif attributes.kind_of?(Hash)
          o.#{CONCAT_METHOD}(#{string_const_name(:PARTIAL_OPEN)})
          attributes.fortitude_append_as_attributes(o, nil)

          if block_given?
            o.#{CONCAT_METHOD}(FORTITUDE_TAG_PARTIAL_OPEN_END)
            yield
            o.#{CONCAT_METHOD}(#{string_const_name(:CLOSE)})
          else
            o.#{CONCAT_METHOD}(FORTITUDE_TAG_PARTIAL_OPEN_ALONE_END)
          end
        else
          o.#{CONCAT_METHOD}(#{string_const_name(:OPEN)})
          attributes.to_s.fortitude_append_escaped_string(o)
          yield if block_given?
          o.#{CONCAT_METHOD}(#{string_const_name(:CLOSE)})
        end
      end
EOS
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
