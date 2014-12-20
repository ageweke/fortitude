require 'active_support/concern'

module ::FortitudeBootstrap
  extend ActiveSupport::Concern

  def _fortitude_bootstrap_add_classes(classes_to_add, content_or_attributes = nil, attributes = nil)
    classes_to_add = Array(classes_to_add)
    passed_content = passed_attributes = nil

    if content_or_attributes.kind_of?(String)
      passed_content = content_or_attributes
      passed_attributes = attributes
    elsif content_or_attributes.kind_of?(Hash)
      passed_attributes = content_or_attributes
    end
    passed_attributes ||= { }

    new_attributes = if passed_attributes.has_key?('class')
      passed_attributes.merge('class' => Array(passed_attributes['class'] || [ ]) + classes_to_add)
    else
      passed_attributes.merge(:class => Array(passed_attributes[:class] || [ ]) + classes_to_add)
    end

    if content_or_attributes.kind_of?(String)
      [ content_or_attributes, new_attributes ]
    else
      [ new_attributes ]
    end
  end

  def self._fortitude_bootstrap_class_adding_method(method_name, tag_name, classes_to_add)
    define_method(method_name) do |*args, &block|
      send(tag_name, *_fortitude_bootstrap_add_classes(classes_to_add, *args), &block)
    end
  end

  _fortitude_bootstrap_class_adding_method :container, :div, :container
  _fortitude_bootstrap_class_adding_method :fluid_container, :div, :'container-fluid'
  _fortitude_bootstrap_class_adding_method :jumbotron, :div, :jumbotron
  _fortitude_bootstrap_class_adding_method :row, :div, :row

  COLUMNS_SPEC_KEYS = [ :xs, :small, :medium, :large ]

  def _fortitude_bootstrap_column_classes(column_spec)
    column_spec.assert_valid_keys(COLUMNS_SPEC_KEYS)
    column_spec.map do |key, number|
      raise TypeError, "Column must be an integer between 1 and 12" unless number.kind_of?(Integer) && (1..12).include?(number)
      class_fragment = case key
      when :xs then 'xs'
      when :small then 'sm'
      when :medium then 'md'
      when :large then 'lg'
      else raise "Invalid class fragment: #{class_fragment.inspect}"
      end
      "col-#{class_fragment}-#{number}"
    end
  end

  def columns(*args, &block)
    column_spec = args[0]

    if args.length == 1 && args[0].kind_of?(Hash)
      attributes = { }
      column_spec = { }
      args[0].each do |key, value|
        if COLUMNS_SPEC_KEYS.include?(key.to_sym)
          column_spec[key] = value
        else
          attributes[key] = value
        end
      end

      args = [ attributes ]
    end

    div(*_fortitude_bootstrap_add_classes(_fortitude_bootstrap_column_classes(column_spec), *args), &block)
  end
end
