# -*- encoding: utf-8 -*-
source "https://rubygems.org"
gemspec

# pin dependency for Ruby 1.9.3 since bundler is not
# detecting that net-ssh 3 does not work with 1.9.3
if Gem::Version.new(RUBY_VERSION) <= Gem::Version.new("1.9.3")
  gem "net-ssh", "~> 2.9"
end

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.2.2")
  gem "json", "< 2.0"
  gem "rack", "< 2.0"
  gem "ruby_dep", "< 1.4.0"
  gem "listen", "< 3.0.0"
end

group :guard do
  gem "guard-rspec",    :require => nil
  gem "guard-rubocop",  :require => nil
end

group :test do
  gem "bundler", "~> 1.10"
  gem "minitest", "~> 5.5"
  gem "rake", "~> 11.0"
  gem "chefstyle", "0.4.0"
  gem "concurrent-ruby", "~> 0.9"
  gem "codeclimate-test-reporter", :require => nil
  gem "rspec"
  gem "simplecov", "~> 0.12"
  gem "countloc", "~> 0.4"
end

group :integration do
  gem "berkshelf", ">= 4.3.5"
  gem "kitchen-dokken"
end

group :tools do
  gem "pry", "~> 0.10"
  gem "github_changelog_generator", "1.13.1"
end
