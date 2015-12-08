# -*- encoding: utf-8 -*-

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rubocop/rake_task'

# Specs
RSpec::Core::RakeTask.new(:spec)

desc "Run all test suites"
task :test => [:spec]

# Rubocop
desc 'Run Rubocop lint checks'
task :rubocop do
  RuboCop::RakeTask.new
end

# lint the project
desc 'Run robocop linter'
task lint: [:rubocop]

desc "Display LOC stats"
task :stats do
  puts "\n## Production Code Stats"
  sh "countloc -r lib/kitchen"
  puts "\n## Test Code Stats"
  sh "countloc -r spec"
end

desc "Run all quality tasks"
task :quality => [:lint, :stats]

task :default => [:test, :quality]

# Automatically generate a changelog for this project. Only loaded if
# the necessary gem is installed.
begin
  require 'github_changelog_generator/task'
  GitHubChangelogGenerator::RakeTask.new :changelog
rescue LoadError
  puts '>>>>> GitHub Changelog Generator not loaded, omitting tasks'
end
