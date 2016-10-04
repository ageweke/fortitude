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

      def rails_server_wraps_template_errors?
        !! (rails_server.actual_rails_version =~ /^5\./)
      end

      def expect_actionview_exception(subpath, class_name, message)
        actual_class_expected = if rails_server_wraps_template_errors?
          'ActionView::Template::Error'
        else
          class_name
        end

        hash = expect_exception(subpath, actual_class_expected, message)

        if rails_server_wraps_template_errors?
          cause = hash['exception']['cause']
          expect(cause).to be
          expect(cause['class']).to eq(class_name.to_s)
        end

        hash
      end
    end
  end
end
