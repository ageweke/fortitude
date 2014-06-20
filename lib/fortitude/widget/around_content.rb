require 'active_support'
require 'active_support/concern'

module Fortitude
  class Widget
    module AroundContent
      extend ActiveSupport::Concern

      module ClassMethods
        # PUBLIC API
        def around_content(*method_names)
          return if method_names.length == 0
          @_fortitude_around_content_methods ||= [ ]
          @_fortitude_around_content_methods += method_names.map { |x| x.to_s.strip.downcase.to_sym }
          rebuild_run_content!(:around_content_added)
        end

        # PUBLIC API
        def remove_around_content(*method_names)
          options = method_names.extract_options!
          options.assert_valid_keys(:fail_if_not_present)

          not_found = [ ]
          method_names.each do |method_name|
            not_found << method_name unless (@_fortitude_around_content_methods || [ ]).delete(method_name)
          end

          rebuild_run_content!(:around_content_removed)
          unless (not_found.length == 0) || (options.has_key?(:fail_if_not_present) && (! options[:fail_if_not_present]))
            raise ArgumentError, "no such methods: #{not_found.inspect}"
          end
        end

        # INTERNAL USE ONLY
        def around_content_methods
          superclass_methods = if superclass.respond_to?(:around_content_methods)
            superclass.around_content_methods
          else
            [ ]
          end

          (superclass_methods + this_class_around_content_methods).uniq
        end

        # INTERNAL USE ONLY
        def this_class_around_content_methods
          @_fortitude_around_content_methods ||= [ ]
        end
        private :this_class_around_content_methods
      end
    end
  end
end
