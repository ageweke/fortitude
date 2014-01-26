require 'fortitude'
require 'helpers/rails_server'

describe "basic Rails integration" do
  before :each do
    @rails_server = Spec::Helpers::RailsServer.new('basic', 'system/rails/template')
    @rails_server.start!
  end

  after :each do
    @rails_server.stop!
  end

  it "should be able to render a trivial widget" do
    data = @rails_server.get('basic_rails_system_spec/trivial_widget')
    $stderr.puts "DATA: #{data.inspect}"
  end
end
