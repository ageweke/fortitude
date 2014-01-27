require 'fortitude'
require 'helpers/rails_helpers'

RSpec.configure do |c|
  c.include RailsHelpers, :type => :rails
end
