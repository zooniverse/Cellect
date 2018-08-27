# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cellect/version'

Gem::Specification.new do |spec|
  spec.name          = 'cellect'
  spec.version       = Cellect::VERSION
  spec.authors       = ['Michael Parrish']
  spec.email         = ['michael@zooniverse.org']
  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = 'https://github.com/parrish/Cellect'
  spec.license       = 'MIT'

  spec.files         = ['lib/cellect.rb', 'lib/cellect/version.rb']
  spec.executables   = []
  spec.test_files    = []
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'oj'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'puma', '~> 2.8'
  spec.add_development_dependency 'pg', '~> 1.1'
  spec.add_development_dependency 'connection_pool', '~> 2.0'
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0.0"

  spec.add_runtime_dependency 'cellect-server', Cellect::VERSION
  spec.add_runtime_dependency 'cellect-client', Cellect::VERSION
end
