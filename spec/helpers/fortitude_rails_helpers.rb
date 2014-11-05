module Spec
  module Helpers
    module FortitudeRailsHelpers
      def rails_server_project_root
        @rails_server_project_root ||= File.expand_path(File.join(File.dirname(__FILE__), '../..'))
      end
    end
  end
end
