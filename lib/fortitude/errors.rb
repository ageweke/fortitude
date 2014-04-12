module Fortitude
  module Errors
    class Base < StandardError; end

    class MissingNeed < Base
      attr_reader :widget, :missing_needs, :assigns

      def initialize(widget, missing_needs, assigns)
        super(%{The widget #{widget} requires the following parameters to render, but they were not supplied: #{missing_needs.sort_by(&:to_s).join(", ")}})
        @widget = widget
        @missing_needs = missing_needs
        @assigns = assigns
      end
    end

    class ExtraAssigns < Base
      attr_reader :widget, :extra_assigns

      def initialize(widget, extra_assigns)
        super(%{The widget #{widget} does not accept the following parameters: #{extra_assigns.keys.sort_by(&:to_s).join(", ")}})
        @widget = widget
        @extra_assigns = extra_assigns
      end
    end

    class InvalidElementNesting < Base
      attr_reader :widget, :enclosing_element_name, :enclosed_element_name

      def initialize(widget, enclosing_element_name, enclosed_element_name)
        super(%{The widget #{widget} tried to render an element that is not allowed by element nesting rules: you can't put a <#{enclosed_element_name}> inside a <#{enclosing_element_name}>.})
        @widget = widget
        @enclosing_element_name = enclosing_element_name
        @enclosed_element_name = enclosed_element_name
      end
    end

    class InvalidElementAttributes < Base
      attr_reader :widget, :element_name, :invalid_attributes_hash, :allowed_attribute_names

      def initialize(widget, element_name, invalid_attributes_hash, allowed_attribute_names)
        super(%{The widget #{widget} tried to render an element, <#{element_name}>, with attributes that are not allowed: #{invalid_attributes_hash.inspect}. Only these attributes are allowed: #{allowed_attribute_names.sort_by(&:to_s).inspect}})
        @widget = widget
        @element_name = element_name
        @invalid_attributes_hash = invalid_attributes_hash
        @allowed_attribute_names = allowed_attribute_names
      end
    end

    class DuplicateId < Base
      attr_reader :widget, :id, :already_used_widget, :already_used_tag_name, :tag_name

      def initialize(widget, id, already_used_widget, already_used_tag_name, tag_name)
        super(%{The widget #{widget} tried to use a DOM ID, '#{id}', that has already been used. It was originally used on a <#{already_used_tag_name}> tag within widget #{already_used_widget}, and is now trying to be used on a <#{tag_name}> tag.})
        @widget = widget
        @id = id
        @already_used_widget = already_used_widget
        @already_used_tag_name = already_used_tag_name
        @tag_name = tag_name
      end
    end

    class DynamicAccessFromStaticMethod < Base
      attr_reader :widget, :static_method_name, :method_called

      def initialize(widget, static_method_name, method_called)
        super(%{The widget class #{widget.class.name} declared method #{static_method_name.inspect} to be static, but, when we went to make it static, we found that it called #{method_called.inspect}, and that accesses dynamic data; this therefore can't possibly be made static safely.})
        @widget = widget
        @static_method_name = static_method_name
        @method_called = method_called
      end
    end

    class NoContentAllowed < Base
      attr_reader :widget, :element_name

      def initialize(widget, element_name)
        super(%{The widget #{widget} tried to render an element, <#{element_name}>, with content inside it, but that element doesn't accept content.})
        @widget = widget
        @element_name = element_name
      end
    end

    class NeedConflictsWithMethod < Base
      attr_reader :widget_class, :need_names

      def initialize(widget_class, need_names)
        super(%{The widget class #{widget_class.name} tried to declare that it needs #{need_names.inspect}, but that/those are already valid method names on the widget class. Pass :fortitude_allow_overriding_methods_with_needs => true if you want to allow this.})
        @widget_class = widget_class
        @need_names = need_names
      end
    end

    class NoReturnValueFromTag < Base
      attr_reader :method_name

      def initialize(method_name)
        super(%{You're trying to call a method, #{method_name.inspect}, on the return value of a Fortitude
tag; tags don't return anything usable. (If you're migrating from Erector, this may
be a place where you used Erector syntax for classes or IDs -- e.g., p.some_class,
div.some_id!. Fortitude doesn't support these for important performance reasons;
you simply need to convert these to "p :class => :some_class" or
"div :id => :some_id".)})
        @method_name = method_name
      end
    end

    class TagNotFound < Base
      attr_reader :tag_store, :tag_name

      def initialize(tag_store, tag_name)
        super(%{The tag store #{tag_store} has no tag named #{tag_name.inspect}.})
        @tag_store = tag_store
        @tag_name = tag_name
      end
    end
  end
end
