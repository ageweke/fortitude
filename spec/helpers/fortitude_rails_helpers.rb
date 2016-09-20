module Spec
  module Helpers
    module FortitudeRailsHelpers
      def rails_server_project_root
        @rails_server_project_root ||= File.expand_path(File.join(File.dirname(__FILE__), '../..'))
      end

      def rails_server_gemfile_modifier
        Proc.new do |gemfile|
          gemfile.set_specs!('fortitude', :path => rails_server_project_root)
        end
      end

      def rails_server_default_version
        ENV['FORTITUDE_SPECS_RAILS_VERSION']
      end
    end
  end
end
