require 'active_support'
require 'active_support/concern'

require 'fortitude/tags/tags_module'

module Fortitude
  class Widget
    module ModulesAndSubclasses
      extend ActiveSupport::Concern

      module ClassMethods
        def all_fortitude_superclasses
          @all_fortitude_superclasses ||= begin
            if self.name == ::Fortitude::Widget.name
              [ ]
            else
              out = [ ]
              klass = superclass
              while true
                out << klass
                break if klass.name == ::Fortitude::Widget.name
                klass = klass.superclass
              end
              out
            end
          end
        end

        # INTERNAL USE ONLY
        def direct_subclasses
          @direct_subclasses || [ ]
        end
        private :direct_subclasses

        # INTERNAL USE ONLY -- RUBY CALLBACK
        def inherited(subclass)
          @direct_subclasses ||= [ ]
          @direct_subclasses |= [ subclass ]
        end

        # INTERNAL USE ONLY
        def create_modules!
          raise "We already seem to have created our modules" if @tags_module || @needs_module || @helpers_module
          @tags_module = Fortitude::Tags::TagsModule.new(self)
          @helpers_module = Module.new
          include @helpers_module
          const_set(:DefinedFortitudeHelpers, @helpers_module)
          @needs_module = Module.new
          include @needs_module
          const_set(:FortitudeNeedsMethods, @helpers_module)
        end
        private :create_modules!

        # INTERNAL USE ONLY
        def tags_module
          create_modules! unless @tags_module
          @tags_module
        end
        private :tags_module

        # INTERNAL USE ONLY
        def needs_module
          create_modules! unless @needs_module
          @needs_module
        end
        private :needs_module

        # INTERNAL USE ONLY
        def helpers_module
          create_modules! unless @helpers_module
          @helpers_module
        end
        private :helpers_module
      end
    end
  end
end
