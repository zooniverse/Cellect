require 'bundler/gem_helper'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks name: 'cellect'
RSpec::Core::RakeTask.new :spec
task default: :spec
