require 'fortitude'
require 'oop_rails_server'
require 'helpers/system_helpers'
require 'helpers/fortitude_rails_helpers'

RSpec.configure do |c|
  c.include ::OopRailsServer::Helpers, :type => :rails
  c.include ::Spec::Helpers::FortitudeRailsHelpers, :type => :rails
  c.include SystemHelpers, :type => :system
end
