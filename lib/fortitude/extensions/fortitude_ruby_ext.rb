require 'erb'

::String.class_eval do
  def fortitude_append_escaped_string(output)
    _fortitude_append_escaped_string(output, false)
  end

  TABLE_FOR_ESCAPE_ATTRIBUTE_VALUE__ = {
    '&' => '&amp;',
    '"' => '&quot;'
  }

  PROC_FOR_ESCAPE_ATTRIBUTE_VALUE__ = Proc.new do |match|
    TABLE_FOR_ESCAPE_ATTRIBUTE_VALUE__[match]
  end

  if RUBY_VERSION =~ /^1\.8\./
    def _fortitude_append_escaped_string_for_value(output)
      output.original_concat(self.gsub(/[&\"]/, &PROC_FOR_ESCAPE_ATTRIBUTE_VALUE__))
    end
  else
    def _fortitude_append_escaped_string_for_value(output)
      output.original_concat(self.gsub(/[&\"]/, TABLE_FOR_ESCAPE_ATTRIBUTE_VALUE__))
    end
  end

  def _fortitude_append_escaped_string(output, for_attribute_value)
    raise ArgumentError, "You can only append to a String" unless output.kind_of?(String)

    if html_safe?
      output.original_concat(self)
    elsif for_attribute_value
      _fortitude_append_escaped_string_for_value(output)
    else
      output.original_concat(ERB::Util.html_escape(self))
    end
  end
end

::Hash.class_eval do
  {
    'FORTITUDE_HYPHEN' => '-',
    'FORTITUDE_EQUALS_QUOTE' => '="',
    'FORTITUDE_QUOTE' => '"',
    'FORTITUDE_SPACE' => ' ',
    'TARGET_BASE' => ""
  }.each do |constant_name, value|
    value = value.html_safe if value.respond_to?(:html_safe)
    value = value.freeze
    const_set(constant_name, value)
  end

  def fortitude_append_as_attributes(output, prefix, allows_bare_attributes)
    raise ArgumentError, "You can only append to a String" unless output.kind_of?(String)

    target = ::Hash::TARGET_BASE.dup

    each do |key, value|
      if value.kind_of?(Hash)
        new_prefix = case prefix
        when String then fortitude_append_to(key, prefix.dup, false)
        when nil then fortitude_append_to(key, "".html_safe, false)
        else raise ArgumentError, "You can only use a String as a prefix"
        end

        new_prefix.original_concat(::Hash::FORTITUDE_HYPHEN)
        value.fortitude_append_as_attributes(target, new_prefix, allows_bare_attributes)
      else
        if value == nil || value == false
          # nothing
        else
          target.original_concat(::Hash::FORTITUDE_SPACE)

          case prefix
          when String then target.original_concat(prefix)
          when nil then nil
          else raise ArgumentError, "You can only use a String as a prefix"
          end

          fortitude_append_to(key, target, false)

          if value == true
            if allows_bare_attributes
              # nothing here
            else
              target.original_concat(::Hash::FORTITUDE_EQUALS_QUOTE)
              fortitude_append_to(key, target, false)
              target.original_concat(::Hash::FORTITUDE_QUOTE)
            end
          else
            target.original_concat(::Hash::FORTITUDE_EQUALS_QUOTE)
            fortitude_append_to(value, target, true)
            target.original_concat(::Hash::FORTITUDE_QUOTE)
          end
        end
      end
    end

    output.original_concat(target)
  end

  private
  def fortitude_append_to(object, output, for_attribute_value)
    case object
    when String then object._fortitude_append_escaped_string(output, for_attribute_value)
    when Symbol then object.to_s._fortitude_append_escaped_string(output, for_attribute_value)
    when Array then object.each_with_index do |o,i|
      output.original_concat(" ") if i > 0
      fortitude_append_to(o, output, for_attribute_value)
    end
    when nil then nil
    when Integer then output.original_concat(object.to_s)
    else object.to_s._fortitude_append_escaped_string(output, for_attribute_value)
    end
  end
end
