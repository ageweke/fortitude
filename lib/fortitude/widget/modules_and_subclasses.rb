require 'active_support'
require 'active_support/concern'

require 'fortitude/tags/tags_module'

module Fortitude
  class Widget
    module ModulesAndSubclasses
      extend ActiveSupport::Concern

      module ClassMethods
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
          @needs_module = Module.new
          include @needs_module
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
