require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'monet'

desc "Runs the site and grabs baselines"
task :baseline do
  config = Monet::Config.load

  Monet.clean config
  Rake::Task["run"].invoke
end

desc "Run the baseline comparison"
task :run do
  config = Monet::Config.load
  Monet.capture config
  Monet.compare config
end

RSpec::Core::RakeTask.new(:test)
task :default => :test
