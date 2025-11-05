# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marsh_grass/version'

Gem::Specification.new do |spec|
  spec.name          = 'marsh_grass'
  spec.version       = MarshGrass::VERSION
  spec.authors       = [
    'Wes Rich',
    'Amanda Pouget'
  ]
  spec.email         = [
    'wes.rich@rolemodelsoftware.com',
    'amanda.pouget@rolemodelsoftware.com'
  ]

  spec.summary       = 'A set of tools to help diagnose random test failures.'
  spec.description   = 'Currently works with RSpec tags to run against possible test failure scenarios.'
  spec.homepage      = 'https://github.com/RoleModel/marsh_grass'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0'

  spec.add_development_dependency 'bundler', '>= 2.0', '< 5.0'
  spec.add_development_dependency 'pry-byebug', '~> 3'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_dependency 'activesupport', '>= 7.1', '< 9.0'
  spec.add_dependency 'rspec', '~> 3.6'
  spec.add_dependency 'rspec-rails', '~> 6'
  spec.add_dependency 'timecop', '~> 0.9'
end
