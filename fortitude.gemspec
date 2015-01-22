# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fortitude/version'

Gem::Specification.new do |s|
  s.name          = "fortitude"
  s.version       = Fortitude::VERSION
  s.authors       = ["Andrew Geweke"]
  s.email         = ["andrew@geweke.org"]
  s.summary       = %q{Views Are Code: use all the power of Ruby to build views in your own language.}
  s.description   = %q{Views Are Code: use all the power of Ruby to build views in your own language.}
  s.homepage      = "https://github.com/ageweke/fortitude"
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  if RUBY_PLATFORM =~ /java/
    s.platform = 'java'
  else
    s.platform = Gem::Platform::RUBY
    s.extensions << "ext/fortitude_native_ext/extconf.rb"
  end

  activesupport_spec = if RUBY_VERSION =~ /^1\.8\./
    [ ">= 3.0", "< 4.0" ]
  else
    [ ">= 3.0" ]
  end

  s.add_dependency "activesupport", *activesupport_spec

  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.99"
  s.add_development_dependency "rake-compiler"
  s.add_development_dependency "json"
  s.add_development_dependency "tilt", "~> 2.0"
  s.add_development_dependency "oop_rails_server", ">= 0.0.6"

  # This is because i18n >= 0.7 is incompatible with Ruby 1.8.x.
  if RUBY_VERSION =~ /^1\.8\./
    s.add_development_dependency "i18n", "~> 0.6.0", "< 0.7.0"
  end
end
