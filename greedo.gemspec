# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'greedo/version'

Gem::Specification.new do |spec|
  spec.name          = "greedo"
  spec.version       = Greedo::VERSION
  spec.authors       = ["Adam Pohorecki"]
  spec.email         = ["adam@pohorecki.pl"]
  spec.summary       = %q{A very simple grid library}
  spec.description   = %q{Shortens the syntax for creating tables}
  spec.homepage      = "https://github.com/gunpowderlabs/greedo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-core"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "rails", "~> 4.2"
  spec.add_development_dependency "sqlite3"

  spec.add_dependency "haml"
  spec.add_dependency "will_paginate"
  spec.add_dependency "will_paginate-bootstrap"
end
