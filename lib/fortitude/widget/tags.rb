require 'active_support'
require 'active_support/concern'

require 'fortitude/tags/tag_store'

module Fortitude
  class Widget
    module Tags
      extend ActiveSupport::Concern

      included do
        extend Fortitude::Tags::TagStore

        class << self
          # INTERNAL USE ONLY
          def tags_changed!(tags)
            super
            rebuild_tag_methods!(:tags_declared, tags)
          end
          private :tags_changed!

          # INTERNAL USE ONLY
          def delegate_tag_stores
            out = [ doctype ]

            out += superclass.delegate_tag_stores if superclass.respond_to?(:delegate_tag_stores)
            out << superclass if superclass.respond_to?(:tags)

            out.compact.uniq
          end
        end
      end

      def validate_can_enclose!(widget, tag_object)
        # ok, nothing here
      end

      module ClassMethods
        # INTERNAL USE ONLY
        def rebuild_tag_methods!(why, which_tags_in = nil, klass = self)
          rebuilding(:tag_methods, why, klass) do
            all_tags = tags.values

            which_tags = Array(which_tags_in || all_tags)
            which_tags.each do |tag_object|
              tag_object.define_method_on!(tags_module,
                :enable_formatting => self.format_output,
                :record_emitting_tag => self._fortitude_record_emitting_tag?,
                :enforce_attribute_rules => self.enforce_attribute_rules,
                :enforce_id_uniqueness => self.enforce_id_uniqueness,
                :close_void_tags => self.close_void_tags,
                :allows_bare_attributes => self.doctype.allows_bare_attributes?)
            end

            direct_subclasses.each { |s| s.rebuild_tag_methods!(why, which_tags_in, klass) }
          end
        end
      end
    end
  end
end
