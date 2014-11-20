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

        File.read(source_file).split(/\r\n|\r|\n/).each do |line|
          needs_end = false
          line = line.chomp

          if line =~ /^(.*)\#\s*\:if\s*(.*?)\s*$/i
            line = $1
            condition = $2
            method_text_lines << "  if #{condition}"
            needs_end = true
          end

          method_text_lines << "    output << \"#{line}\\n\""
          method_text_lines << "  end" if needs_end
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

        def method_missing(name, *args)
          raise "Method missing: #{name.inspect} with arguments: #{args.inspect}" if args.length > 0
          return @hash[name] if @hash.key?(name)
          raise "Method missing: #{name.inspect}; have no match: #{@hash.keys.inspect}"
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
