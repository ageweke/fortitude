require 'active_support/concern'

module ::FortitudeBootstrap
  extend ActiveSupport::Concern

  def self._fortitude_bootstrap_class_adding_method(method_name, tag_name, classes_to_add)
    define_method(method_name) do |*args, &block|
      send(tag_name, *add_css_classes(classes_to_add, *args), &block)
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

    div(*add_css_classes(_fortitude_bootstrap_column_classes(column_spec), *args), &block)
  end
end
