require 'active_support'
require 'json'
require 'helpers/rails_server'

module RailsHelpers
  extend ActiveSupport::Concern

  included do
    before :all do
      @rails_server = Spec::Helpers::RailsServer.new('basic', 'system/rails/template')
      @rails_server.start!
    end

    after :all do
      @rails_server.stop!
    end
  end

  def get(subpath)
    @rails_server.get("basic_rails_system_spec/#{subpath}")
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

  end
end
