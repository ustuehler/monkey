require 'rake/clean'
require 'rspec/core/rake_task'
require 'rubygems/package_task'

CLOBBER.include 'Gemfile.lock'

task :default => [:spec]

RSpec::Core::RakeTask.new :spec

gemspec = eval(File.read('office_monkey.gemspec'))

Gem::PackageTask.new(gemspec) do |pkg|
  # Nothing to configure; defaults are okay
end
