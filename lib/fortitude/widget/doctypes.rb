require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module Doctypes
      extend ActiveSupport::Concern

      # PUBLIC API
      def doctype(s)
        tag_rawtext "<!DOCTYPE #{s}>"
      end

      # PUBLIC API
      def doctype!
        dt = self.class.doctype
        raise "You must set a doctype at the class level, using something like 'doctype :html5', before you can use this method." unless dt
        dt.declare!(self)
      end

      module ClassMethods
        # PUBLIC API
        def doctype(new_doctype = nil)
          if new_doctype
            new_doctype = case new_doctype
            when Fortitude::Doctypes::Base then new_doctype
            when Symbol then Fortitude::Doctypes.standard_doctype(new_doctype)
            else raise ArgumentError, "You must supply a Symbol or an instance of Fortitude::Doctypes::Base, not: #{new_doctype.inspect}"
            end

            current_doctype = doctype
            if current_doctype
              if new_doctype != current_doctype
                raise ArgumentError, "The doctype has already been set to #{current_doctype} on this widget class or a superclass. You can't set it to #{new_doctype}; if you want to use a different doctype, you will need to make a new subclass that has no doctype set yet."
              end
            end

            if new_doctype.close_void_tags_must_be != nil
              self.close_void_tags(new_doctype.close_void_tags_must_be)
            end

            @_fortitude_doctype = new_doctype
            tags_added!(new_doctype.tags.values)
          else
            return @_fortitude_doctype if @_fortitude_doctype
            return superclass.doctype if superclass.respond_to?(:doctype)
            nil
          end
        end
      end
    end
  end
end
