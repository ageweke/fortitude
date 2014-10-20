require 'active_support'
require 'json'
require 'helpers/rails_server'

module RailsHelpers
  extend ActiveSupport::Concern

  attr_reader :rails_server


  def full_path(subpath)
    "#{rails_template_name}/#{subpath}"
  end

  def get(subpath, options = { })
    rails_server.get(full_path(subpath), options)
  end

  def get_response(subpath, options = { })
    rails_server.get_response(full_path(subpath), options)
  end

  def get_success(subpath, options = { })
    data = get(subpath, options)
    data.should match(/rails_spec_application/i) unless options[:no_layout]
    data
  end

  def expect_match(subpath, *args)
    options = args.extract_options!
    regexes = args

    data = get_success(subpath, options)
    regexes.each do |regex|
      data.should match(regex)
    end

    data
  end

  def expect_exception(subpath, class_name, message)
    data = get(subpath)

    json = begin
      JSON.parse(data)
    rescue => e
      raise %{Expected a JSON response from '#{subpath}' (because we expected an exception),
but we couldn't parse it as JSON; when we tried, we got:

(#{e.class.name}) #{e.message}

The data is:

#{data.inspect}}
    end

    json['exception'].should be
    json['exception']['class'].should == class_name.to_s
    json['exception']['message'].should match(message)
  end

  def rails_template_name
    @rails_template_name || raise("No Rails template name!")
  end

  def rails_server_project_root
    @rails_server_project_root ||= File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  end

  def rails_server_templates_root
    @rails_server_templates_root ||= File.join(rails_server_project_root, "spec/rails/templates")
  end

  def rails_server_runtime_base_directory
    @rails_server_runtime_base_directory ||= File.join(rails_server_project_root, "tmp/spec/rails")
  end

  module ClassMethods
    def uses_rails_with_template(template_name, options = { })
      before :all do
        @rails_template_name = template_name

        templates = [ 'base', template_name ].map do |t|
          File.join(rails_server_templates_root, t.to_s)
        end
        additional_gemfile_lines = [ "gem 'fortitude', :path => '#{rails_server_project_root}'" ]
        additional_gemfile_lines += Array(options[:additional_gemfile_lines] || [ ])

        @rails_server = Spec::Helpers::RailsServer.new(
          :name => template_name, :template_paths => templates, :runtime_base_directory => rails_server_runtime_base_directory,
          :rails_version => (ENV['FORTITUDE_SPECS_RAILS_VERSION'] || options[:rails_version]),
          :rails_env => options[:rails_env], :additional_gemfile_lines => additional_gemfile_lines)

        @rails_server.start!
      end

      after :all do
        @rails_server.stop!
      end
    end
  end
end
