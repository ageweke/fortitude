module Fortitude
  module Errors
    class Base < StandardError; end

    class MissingNeed < Base
      attr_reader :widget, :missing_needs, :assigns

      def initialize(widget, missing_needs, assigns)
        super(%{The widget #{widget.class.name} requires the following parameters to render, but they were not supplied: #{missing_needs.sort_by(&:to_s).join(", ")}})
        @widget = widget
        @missing_needs = missing_needs
        @assigns = assigns
      end
    end

    class ExtraAssigns < Base
      attr_reader :widget, :extra_assigns

      def initialize(widget, extra_assigns)
        super(%{The widget #{widget.class.name} does not accept the following parameters: #{extra_assigns.keys.sort_by(&:to_s).join(", ")}})
        @widget = widget
        @extra_assigns = extra_assigns
      end
    end

    class InvalidElementNesting < Base
      attr_reader :widget, :enclosing_element_name, :enclosed_element_name

      def initialize(widget, enclosing_element_name, enclosed_element_name)
        super(%{The widget #{widget.class.name} tried to render an element that is not allowed by element nesting rules: you can't put a <#{enclosed_element_name}> inside a <#{enclosing_element_name}>.})
        @widget = widget
        @enclosing_element_name = enclosing_element_name
        @enclosed_element_name = enclosed_element_name
      end
    end

    class InvalidElementAttributes < Base
      attr_reader :widget, :element_name, :invalid_attributes_hash, :allowed_attribute_names

      def initialize(widget, element_name, invalid_attributes_hash, allowed_attribute_names)
        super(%{The widget #{widget.class.name} tried to render an element, <#{element_name}>, with attributes that are not allowed: #{invalid_attributes_hash.inspect}. Only these attributes are allowed: #{allowed_attribute_names.inspect}})
        @widget = widget
        @element_name = element_name
        @invalid_attributes_hash = invalid_attributes_hash
        @allowed_attribute_names = allowed_attribute_names
      end
    end
  end
end
