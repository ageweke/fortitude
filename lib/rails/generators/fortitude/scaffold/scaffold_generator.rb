require 'rails/generators/erb/scaffold/scaffold_generator'

module Fortitude
  module Generators
    class ScaffoldGenerator < Erb::Generators::ScaffoldGenerator
      source_root File.join(File.dirname(__FILE__), 'templates')

      def copy_view_files
        available_views.each do |view|
          filename = filename_with_extensions(view)
          template "#{view}.html.rb", File.join("app/views", controller_file_path, filename)
        end
      end

      def create_view_base
        generate "fortitude:base_view"
      end

      protected
      def available_views
        %w(index new show edit form)
      end

      def handler
        :rb
      end
    end
  end
end
