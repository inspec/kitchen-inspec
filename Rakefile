# -*- encoding: utf-8 -*-

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "chefstyle"
require "rubocop/rake_task"

# Specs
RSpec::Core::RakeTask.new(:spec)

desc "Run all test suites"
task test: [:spec]

# Rubocop
desc "Run Rubocop lint checks"
task :rubocop do
  RuboCop::RakeTask.new
end

# lint the project
desc "Run robocop linter"
task lint: [:rubocop]

desc "Display LOC stats"
task :stats do
  puts "\n## Production Code Stats"
  sh "countloc -r lib/kitchen"
  puts "\n## Test Code Stats"
  sh "countloc -r spec"
end

desc "Run all quality tasks"
task quality: [:lint, :stats]

task default: [:test, :quality]

namespace :test do
  task :integration do
    concurrency = ENV["CONCURRENCY"] || 1
    os = ENV["OS"] || ""
    sh("sh", "-c", "bundle exec kitchen test -c #{concurrency} #{os}")
  end
end
