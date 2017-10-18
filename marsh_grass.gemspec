# frozen_string_literal: true

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marsh_grass/version'

Gem::Specification.new do |spec|
  spec.name          = 'marsh_grass'
  spec.version       = MarshGrass::VERSION
  spec.authors       = [
    'Wes Rich',
    'Amanda Simon'
  ]
  spec.email         = [
    'wes.rich@rolemodelsoftware.com',
    'amanda.simon@rolemodelsoftware.com'
  ]

  spec.summary       = %q{A set of tools to help diagnose random test failures.}
  spec.description   = %q{Currently works with RSpec tags to run against possible test failure scenarios.}
  spec.homepage      = ""
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry-byebug', '~> 0'
  spec.add_development_dependency 'pry-doc', '~> 0'
  spec.add_dependency 'rspec', '~> 3.6'
  spec.add_dependency 'timecop', '~> 0'
end
