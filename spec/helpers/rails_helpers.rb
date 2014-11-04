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
    rails_server.name
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

  def rails_server_additional_gemfile_lines
    [
      "gem 'fortitude', :path => '#{rails_server_project_root}'"
    ]
  end

  def rails_server_default_version
    ENV['FORTITUDE_SPECS_RAILS_VERSION']
  end

  def rails_servers
    @rails_servers ||= { }
  end

  def rails_server
    if rails_servers.size == 1
      rails_servers[rails_servers.keys.first]
    elsif rails_servers.size == 0
      raise "No Rails servers have been started!"
    else
      raise "Multiple Rails servers have been started; you must specify which one you want: #{rails_servers.keys.join(", ")}"
    end
  end

  def start_rails_server!(options = { })
    templates = Array(options[:templates] || options[:name] || [ ])
    raise "You must specify a template" unless templates.length >= 1

    name = options[:name]
    name ||= templates[0] if templates.length == 1
    name = name.to_s.strip
    raise "You must specify a name" unless name && name.to_s.strip.length > 0

    server = rails_servers[name]
    server ||= begin
      templates = [ 'base' ] + templates unless options[:skip_base_template]

      template_paths = templates.map do |t|
        File.join(rails_server_templates_root, t.to_s)
      end

      additional_gemfile_lines = Array(rails_server_additional_gemfile_lines || [ ])
      additional_gemfile_lines += Array(options[:additional_gemfile_lines] || [ ])

      server = Spec::Helpers::RailsServer.new(
        :name => name, :template_paths => template_paths,
        :runtime_base_directory => rails_server_runtime_base_directory,
        :rails_version => (options[:rails_version] || rails_server_default_version),
        :rails_env => options[:rails_env], :additional_gemfile_lines => additional_gemfile_lines)

      rails_servers[name] = server

      server
    end

    server.start!
  end

  def stop_rails_servers!
    exceptions = [ ]
    rails_servers.each do |name, server|
      begin
        server.stop!
      rescue => e
        exceptions << [ name, e ]
      end
    end

    raise "Unable to stop all Rails servers! Got:\n#{exceptions.join("\n")}" if exceptions.length > 0
  end

  module ClassMethods
    def uses_rails_with_template(template_name, options = { })
      before :all do
        start_rails_server!({ :templates => [ template_name ] }.merge(options))
      end

      after :all do
        stop_rails_servers!
      end
    end
  end
end
