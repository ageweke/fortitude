begin
  gem 'tilt'
rescue Gem::LoadError => le
  # ok
end

begin
  require 'tilt'
rescue LoadError => le
  # ok, whatever
end

if defined?(::Tilt)
  require 'fortitude/tilt/fortitude_template'

  Tilt.register(Fortitude::Tilt::FortitudeTemplate, 'rb')
end
