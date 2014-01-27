require 'active_support'
require 'json'
require 'helpers/rails_server'

module RailsHelpers
  extend ActiveSupport::Concern

  def rails_template_name
    @rails_template_name || raise("No Rails template name!")
  end

  def get(subpath)
    @rails_server.get("#{rails_template_name}/#{subpath}")
  end

  def get_success(subpath)
    data = get(subpath)
    data.should match(/rails_spec_application/i)
    data
  end

  def expect_match(subpath, *regexes)
    data = get_success(subpath)
    regexes.each do |regex|
      data.should match(regex)
    end
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

    def uses_rails_with_template(template_name)
      before :all do
        @rails_template_name = template_name

        templates = [ 'base', template_name ].map { |t| "system/rails/templates/#{t}" }

        @rails_server = Spec::Helpers::RailsServer.new(template_name, templates)
        @rails_server.start!
      end

      after :all do
        @rails_server.stop!
      end
    end
  end
end
