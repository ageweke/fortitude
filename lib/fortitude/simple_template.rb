module Fortitude
  class SimpleTemplate
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

        while l =~ /\#\{([^}]+)\}/
          name = $1
          value = bindings_target.send($1)
          l = l.gsub("\#\{#{$1}\}", value)
        end

        result_lines << l
      end

      result_lines.join("\n")
    end
  end
end
