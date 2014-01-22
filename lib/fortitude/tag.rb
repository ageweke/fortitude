module Fortitude
  class Tag
    attr_reader :name

    def initialize(name, options = { })
      @name = name.to_s.strip.downcase.to_sym
      @options = options
    end

    def define_method_on!(mod)
      mod.const_set(:FORTITUDE_TAG_PARTIAL_OPEN_END, ">".freeze) unless mod.const_defined?(:FORTITUDE_TAG_PARTIAL_OPEN_END)
      mod.const_set(:FORTITUDE_TAG_PARTIAL_OPEN_ALONE_END, "/>".freeze) unless mod.const_defined?(:FORTITUDE_TAG_PARTIAL_OPEN_ALONE_END)

      mod.const_set(const_name(:ALONE), "<#{name}/>".freeze)
      mod.const_set(const_name(:OPEN), "<#{name}>".freeze)
      mod.const_set(const_name(:CLOSE), "</#{name}>".freeze)
      mod.const_set(const_name(:PARTIAL_OPEN), "<#{name}".freeze)

      mod.module_eval <<-EOS
      def #{name}(attributes = nil)
        o = @output

        if (! attributes)
          if block_given?
            o << #{const_name(:OPEN)}
            yield
            o << #{const_name(:CLOSE)}
          else
            o << #{const_name(:ALONE)}
          end
        elsif attributes.kind_of?(String)
          o << #{const_name(:OPEN)}
          o << attributes
          o << #{const_name(:CLOSE)}
        else
          o << #{const_name(:PARTIAL_OPEN)}
          _attributes(attributes)

          if block_given?
            o << FORTITUDE_TAG_PARTIAL_OPEN_END
            yield
            o << #{const_name(:CLOSE)}
          else
            o << FORTITUDE_TAG_PARTIAL_OPEN_ALONE_END
          end
        end
      end
EOS
    end

    private
    def const_name(key)
      "FORTITUDE_TAG_#{name.upcase}_#{key}".to_sym
    end

    def set_const(mod, key, value)
      the_const_name = const_name(key)
      mod.send(:remove_const, the_const_name) if mod.const_defined?(the_const_name)
      mod.const_set(the_const_name, value.freeze)
    end
  end
end
