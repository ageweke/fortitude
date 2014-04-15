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

    class BlockPassedToNeedMethod < Base
      attr_reader :widget, :method_name

      def initialize(widget, method_name)
        super(%{You passed a block to a method that's a 'needs' method of a Fortitude widget, #{widget}. } +
          %{This can mean you've declared a 'need' with the same name as a Fortitude tag method (e.g., "needs :#{method_name}"), } +
          %{and think you're calling the method that will generate that tag, when you're actually calling a method } +
          %{that will ignore the block you passed and just return the value of that 'need'. If that is the case, try } +
          %{calling the tag with 'tag_' prefixed to it (e.g., 'tag_#{method_name}'), which does the same thing; if not, remove } +
          %{the block and try again.})
        @widget = widget
        @method_name = method_name
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

      def initialize(widget, enclosing_tag, enclosed_tag)
        message = %{The widget #{widget} tried to render an element that is not allowed by element nesting rules: you can't put a <#{enclosed_tag.name}> inside a <#{enclosing_tag.name}>.}
        if enclosing_tag.spec
          message << " (See '#{enclosing_tag.spec}' for more details.)"
        end

        super(message)
        @widget = widget
        @enclosing_tag = enclosing_tag
        @enclosed_tag = enclosed_tag
      end

      def enclosing_tag_name
        @enclosing_tag.name
      end

      def enclosed_tag_name
        @enclosed_tag.name
      end
    end

    class InvalidElementAttributes < Base
      attr_reader :widget, :invalid_attributes_hash, :allowed_attribute_names

      def initialize(widget, tag, invalid_attributes_hash, allowed_attribute_names)
        message = %{The widget #{widget} tried to render an element, <#{tag.name}>, with attributes that are not allowed: #{invalid_attributes_hash.inspect}. Only these attributes are allowed: #{allowed_attribute_names.sort_by(&:to_s).inspect}}
        if tag.spec
          message << " (See '#{tag.spec}' for more details.)"
        end

        super(message)
        @widget = widget
        @tag = tag
        @invalid_attributes_hash = invalid_attributes_hash
        @allowed_attribute_names = allowed_attribute_names
      end

      def tag_name
        @tag.name
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
      attr_reader :widget

      def initialize(widget, tag)
        message = %{The widget #{widget} tried to render an element, <#{tag.name}>, with content inside it, but that element doesn't accept content.}
        if tag.spec
          message << " (See '#{tag.spec}' for more details.)"
        end

        super(message)
        @widget = widget
        @tag = tag
      end

      def tag_name
        @tag
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
