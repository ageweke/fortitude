require 'rails/generators/erb/mailer/mailer_generator'

module Fortitude
  module Generators
    class MailerGenerator < ::Erb::Generators::MailerGenerator
      source_root File.expand_path("../templates", __FILE__)

      def create_view_base
        generate "fortitude:base_view"
      end

      protected
      def handler
        :rb
      end

      def formats
        [:html]
      end
    end
  end
end
