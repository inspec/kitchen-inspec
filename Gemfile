# -*- encoding: utf-8 -*-
source "https://rubygems.org"
gemspec

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
