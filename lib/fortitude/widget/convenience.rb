require 'active_support/concern'

module Fortitude
  class Widget
    module Convenience
      def content_and_attributes_from_tag_arguments(content_or_attributes = nil, attributes = nil)
        if (! attributes) && content_or_attributes.kind_of?(Hash)
          [ nil, (content_or_attributes || { }) ]
        else
          [ content_or_attributes, (attributes || { }) ]
        end
      end

      def add_css_classes(classes_to_add, a = nil, b = nil)
        classes_to_add = Array(classes_to_add)
        content, attributes = content_and_attributes_from_tag_arguments(a, b)

        attributes = if attributes.has_key?('class')
          attributes.merge('class' => (Array(attributes['class'] || [ ]) + classes_to_add))
        else
          attributes.merge(:class => (Array(attributes[:class] || [ ]) + classes_to_add))
        end

        [ content, attributes ]
      end

      alias_method :add_css_class, :add_css_classes
    end
  end
end
