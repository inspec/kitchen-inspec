# -*- encoding: utf-8 -*-

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "chefstyle"
require "rubocop/rake_task"

# Specs
RSpec::Core::RakeTask.new(:spec)

desc "Run all test suites"
task :test => [:spec]

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
task :quality => [:lint, :stats]

task :default => [:test, :quality]

# Automatically generate a changelog for this project. Only loaded if
# the necessary gem is installed.
begin
  require "github_changelog_generator/task"
  GitHubChangelogGenerator::RakeTask.new :changelog
rescue LoadError
  puts ">>>>> GitHub Changelog Generator not loaded, omitting tasks"
end

# Print the current version of this gem or update it.
#
# @param [Type] target the new version you want to set, or nil if you only want to show
def kitchen_inspec_version(target = nil)
  path = "lib/kitchen/verifier/inspec_version.rb"
  require_relative path.sub(/.rb$/, "")

  nu_version = target.nil? ? "" : " -> #{target}"
  puts "Kitchen-inspec: #{Kitchen::Verifier::INSPEC_VERSION}#{nu_version}"

  unless target.nil?
    raw = File.read(path)
    nu = raw.sub(/INSPEC_VERSION.*/, "INSPEC_VERSION = \"#{target}\"")
    File.write(path, nu)
    load(path)
  end
end

# Check if a command is available
#
# @param [Type] x the command you are interested in
# @param [Type] msg the message to display if the command is missing
def require_command(x, msg = nil)
  return if system("command -v #{x} || exit 1")
  msg ||= "Please install it first!"
  puts "\033[31;1mCan't find command #{x.inspect}. #{msg}\033[0m"
  exit 1
end

# Check if a required environment variable has been set
#
# @param [String] x the variable you are interested in
# @param [String] msg the message you want to display if the variable is missing
def require_env(x, msg = nil)
  exists = `env | grep "^#{x}="`
  return unless exists.empty?
  puts "\033[31;1mCan't find environment variable #{x.inspect}. #{msg}\033[0m"
  exit 1
end

# Check the requirements for running an update of this repository.
def check_update_requirements
  require_command "git"
  require_command "github_changelog_generator", "\n"\
    "For more information on how to install it see:\n"\
    "  https://github.com/skywinder/github-changelog-generator\n"
  require_env "CHANGELOG_GITHUB_TOKEN", "\n"\
    "Please configure this token to make sure you can run all commands\n"\
    "against GitHub.\n\n"\
    "See github_changelog_generator homepage for more information:\n"\
    "  https://github.com/skywinder/github-changelog-generator\n"
end

# Show the current version of this gem.
desc "Show the version of this gem"
task :version do
  kitchen_inspec_version
end

desc "Generate the changelog"
task :changelog do
  require_relative "lib/kitchen/verifier/inspec_version"
  system "github_changelog_generator -u chef -p kitchen-inspec --future-release #{Kitchen::Verifier::INSPEC_VERSION}"
end

# Update the version of this gem and create an updated
# changelog. It covers everything short of actually releasing
# the gem.
desc "Bump the version of this gem"
task :bump_version, [:version] do |_, args|
  v = args[:version] || ENV["to"]
  raise "You must specify a target version!  rake release[1.2.3]" if v.empty?
  check_update_requirements
  kitchen_inspec_version(v)
  Rake::Task["changelog"].invoke
end

namespace :test do
  task :integration do
    concurrency = ENV["CONCURRENCY"] || 1
    os = ENV["OS"] || ""
    sh("sh", "-c", "bundle exec kitchen test -c #{concurrency} #{os}")
  end
end
