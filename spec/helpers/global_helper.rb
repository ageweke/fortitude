require 'fortitude'
require 'helpers/rails_helpers'
require 'helpers/system_helpers'

RSpec.configure do |c|
  c.include RailsHelpers, :type => :rails
  c.include SystemHelpers, :type => :system
end
