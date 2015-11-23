# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cellect/version'

Gem::Specification.new do |spec|
  spec.name          = 'cellect-client'
  spec.version       = Cellect::VERSION
  spec.authors       = ['Michael Parrish']
  spec.email         = ['michael@zooniverse.org']
  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = 'https://github.com/parrish/Cellect'
  spec.license       = 'MIT'

  ignored_paths = %w(config data log script tmp).collect{ |path| Dir["#{ path }/**/*"] }.flatten
  ignored_files = %w(Dockerfile Vagrantfile Gemfile.lock config.ru) + ignored_paths

  spec.files         = `git ls-files -z`.split("\x0").reject{ |f| f =~ /server/ } - ignored_files
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'oj'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'pry'

  spec.add_runtime_dependency 'celluloid', '0.16.0'
  spec.add_runtime_dependency 'celluloid-io', '0.16.0'
  spec.add_runtime_dependency 'http', '~> 0.9'
  spec.add_runtime_dependency 'zk', '~> 1.9'
  spec.add_runtime_dependency 'multi_json', '~> 1.11'
end
