require 'sysrandom/securerandom'
require 'rspec/core/rake_task'

desc 'Run tests'
RSpec::Core::RakeTask.new(:spec)

desc 'Start application'
task :rackup do
  system({ 'SESSION_SECRET' => SecureRandom.hex(64) }, 'rackup')
end

task :default => ['rackup']
