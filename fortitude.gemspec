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
  s.homepage      = ""
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.14"
end
