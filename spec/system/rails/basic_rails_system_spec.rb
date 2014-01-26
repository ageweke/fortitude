require 'fortitude'
require 'helpers/rails_server'
require 'json'

describe "basic Rails integration" do
  before :all do
    @rails_server = Spec::Helpers::RailsServer.new('basic', 'system/rails/template')
    @rails_server.start!
  end

  after :all do
    @rails_server.stop!
  end

  def get(subpath)
    @rails_server.get("basic_rails_system_spec/#{subpath}")
  end

  def get_success(subpath)
    data = get(subpath)
    data.should match(/rails_spec_application/i)
    data
  end

  def expect_exception(path, class_name, message)
    data = @rails_server.get(path)

    json = begin
      JSON.parse(data)
    rescue => e
      raise %{Expected a JSON response from '#{path}' (because we expected an exception),
but we couldn't parse it as JSON; when we tried, we got:

(#{e.class.name}) #{e.message}

The data is:

#{data.inspect}}
    end

    json['exception'].should be
    json['exception']['class'].should == class_name.to_s
    json['exception']['message'].should match(message)
  end

  it "should be able to render a trivial widget" do
    data = get_success("trivial_widget")
    data.should match(/layout_default/i)
    data.should match(/hello, world/i)
  end

  it "should not allow you to put Foo::Bar in app/views/foo/bar.rb and make it work" do
    expect_exception('basic_rails_system_spec/the_class_should_not_load', 'NameError',
      /uninitialized constant BasicRailsSystemSpecController::BasicRailsSystemSpec/i)
  end

  it "should allow passing data to the widget through controller variables" do
    data = get_success("passing_data_widget")
    data.should match(/foo is: the_foo/i)
    data.should match(/bar is: and_bar/i)
  end
end
