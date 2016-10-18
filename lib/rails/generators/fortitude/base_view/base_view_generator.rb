require 'rails/generators/erb/controller/controller_generator'

module Fortitude
  module Generators
    class BaseViewGenerator < ::Rails::Generators::Base
      source_root File.join(File.dirname(__FILE__), 'templates')

      def create_view_base
        template "views_base.rb", 'app/views/base.rb', :skip => true
      end
    end
  end
end
