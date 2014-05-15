require 'bundler/gem_helper'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks name: 'cellect'
Bundler::GemHelper.install_tasks name: 'cellect-server'
Bundler::GemHelper.install_tasks name: 'cellect-client'

RSpec::Core::RakeTask.new :spec
task default: :spec
