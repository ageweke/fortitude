require 'erb'

::String.class_eval do
  def fortitude_append_escaped_string(output)
    raise ArgumentError, "You can only append to a String" unless output.kind_of?(String)

    if html_safe?
      output.original_concat(self)
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

  def fortitude_append_as_attributes(output, prefix)
    raise ArgumentError, "You can only append to a String" unless output.kind_of?(String)

    target = ::Hash::TARGET_BASE.dup

    each do |key, value|
      if value.kind_of?(Hash)
        new_prefix = case prefix
        when String then fortitude_append_to(key, prefix.dup)
        when nil then fortitude_append_to(key, "".html_safe)
        else raise ArgumentError, "You can only use a String as a prefix"
        end

        new_prefix.original_concat(::Hash::FORTITUDE_HYPHEN)
        value.fortitude_append_as_attributes(target, new_prefix)
      else
        target.original_concat(::Hash::FORTITUDE_SPACE)

        case prefix
        when String then target.original_concat(prefix)
        when nil then nil
        else raise ArgumentError, "You can only use a String as a prefix"
        end

        fortitude_append_to(key, target)
        target.original_concat(::Hash::FORTITUDE_EQUALS_QUOTE)
        fortitude_append_to(value, target)
        target.original_concat(::Hash::FORTITUDE_QUOTE)
      end
    end

    output.original_concat(target)
  end

  private
  def fortitude_append_to(object, output)
    case object
    when String then object.fortitude_append_escaped_string(output)
    when Symbol then object.to_s.fortitude_append_escaped_string(output)
    when Array then object.each_with_index do |o,i|
      output.original_concat(" ") if i > 0
      fortitude_append_to(o, output)
    end
    when nil then nil
    when Integer then output.original_concat(object.to_s)
    else object.to_s.fortitude_append_escaped_string(output)
    end
  end
end
