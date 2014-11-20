require 'active_support'
require 'active_support/core_ext/hash'

module Fortitude
  module MethodTemplates
    class SimpleCompiledTemplate
      class << self
        def template(name)
          @templates ||= { }
          @templates[name] ||= new(File.join(File.dirname(__FILE__), "#{name}.rb.smpl"))
        end
      end

      def initialize(source_file)
        @source_file = source_file
        method_text_lines = [
          "def result",
          "  output = ''"
        ]
        pending_fixed_strings = [ ]

        File.read(source_file).split(/\r\n|\r|\n/).each do |line|
          needs_end = false
          line = line.chomp

          if line =~ /^(.*)\#\s*\:if\s*(.*?)\s*$/i
            if pending_fixed_strings.length > 0
              method_text_lines << "    output << <<EOS"
              method_text_lines += pending_fixed_strings
              method_text_lines << "EOS"
              pending_fixed_strings = [ ]
            end

            line = $1
            condition = $2
            method_text_lines << "  if #{condition}"
            method_text_lines << "    output << <<EOS"
            method_text_lines << line
            method_text_lines << "EOS"
            method_text_lines << "  end"
          else
            pending_fixed_strings << line
          end
        end

        if pending_fixed_strings.length > 0
          method_text_lines << "    output << <<EOS"
          method_text_lines += pending_fixed_strings
          method_text_lines << "EOS"
          pending_fixed_strings = [ ]
        end

        method_text_lines << "  output"
        method_text_lines << "end"

        @method_text = method_text_lines.join("\n")
        @evaluation_object = EvaluationObject.new
        metaclass = (class << @evaluation_object; self; end)
        metaclass.class_eval(method_text_lines.join("\n"))
      end

      class EvaluationObject
        def initialize
          @hash = nil
        end

        def hash=(h)
          @hash = h.symbolize_keys
        end

        def define_hash_method!(name)
          symbol_name = name.to_sym
          string_name = name.to_s

          metaclass = (class << self; self; end)
          metaclass.send(:define_method, name) do
            @hash[symbol_name]
          end
        end

        def method_missing(name, *args)
          define_hash_method!(name)
          send(name, *args)
        end
      end

      def result(bindings)
        @evaluation_object.hash = bindings
        out = @evaluation_object.result
        out
      end
    end
  end
end
