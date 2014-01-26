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

  it "should do something" do
    3.should == 3
  end
end
