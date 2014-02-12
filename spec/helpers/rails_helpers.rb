require 'active_support'
require 'json'
require 'helpers/rails_server'

module RailsHelpers
  extend ActiveSupport::Concern

  attr_reader :rails_server

  def rails_template_name
    @rails_template_name || raise("No Rails template name!")
  end

  def full_path(subpath)
    "#{rails_template_name}/#{subpath}"
  end

  def get(subpath, options = { })
    @rails_server.get(full_path(subpath), options)
  end

  def get_response(subpath, options = { })
    @rails_server.get_response(full_path(subpath), options)
  end

  def get_success(subpath, options = { })
    data = get(subpath)
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

  module ClassMethods
    def rails_template_name
      @rails_template_name || raise("No Rails template name!")
    end

    def uses_rails_with_template(template_name, options = { })
      before :all do
        @rails_template_name = template_name

        templates = [ 'base', template_name ].map { |t| "rails/templates/#{t}" }

        @rails_server = Spec::Helpers::RailsServer.new(template_name, templates, options)
        @rails_server.start!
      end

      after :all do
        @rails_server.stop!
      end
    end
  end
end
