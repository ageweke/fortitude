require 'active_support'
require 'active_support/core_ext/hash'

module Fortitude
  class SimpleTemplate
    class << self
      def template(name)
        @templates ||= { }
        @templates[name] ||= new(File.join(File.dirname(__FILE__), "method_templates", "#{name}.rb.smpl"))
      end
    end

    def initialize(source_file)
      @lines = File.read(source_file).split(/\r\n|\r|\n/)
    end

    def result(bindings)
      bindings = bindings.stringify_keys
      bindings_target = Object.new
      bindings.each do |key, value|
        (class << bindings_target; self; end).send(:define_method, key) { value }
      end

      result_lines = [ ]
      @lines.each do |l|
        if l =~ /^(.*)\#\s*\:if\s*(.*?)\s*$/i
          l, condition = $1, $2
          next unless bindings_target.instance_eval(condition)
        end

        while l =~ /[^\\]\#\{([^}]+)\}/ || l =~ /^\#\{([^}]+)\}/
          name = $1
          begin
            value = bindings_target.send($1)
          rescue => e
            raise "Failed when processing #{l.inspect}: #{e.inspect}"
          end
          l = l.gsub("\#\{#{$1}\}", value.to_s)
        end
        l = l.gsub(/\\\#\{/, "\#\{")

        result_lines << l
      end

      result_lines.join("\n")
    end
  end
end
