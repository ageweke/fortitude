require 'active_support/concern'

module Fortitude
  module TagSupport
    extend ActiveSupport::Concern

    FORTITUDE_TAG_PARTIAL_OPEN_END = ">".freeze
    FORTITUDE_TAG_PARTIAL_OPEN_ALONE_END = "/>".freeze

    module ClassMethods
      def fortitude_tag_support_included?
        true
      end
    end
  end
end
