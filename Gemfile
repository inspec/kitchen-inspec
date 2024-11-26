# -*- encoding: utf-8 -*-
source "https://rubygems.org"
gemspec

gem "chef-test-kitchen-enterprise", git: "https://github.com/chef/chef-test-kitchen-enterprise", branch: "main"

group :guard do
  gem "guard-rspec",    require: nil
  gem "guard-rubocop",  require: nil
end

group :test do
  gem "minitest", "~> 5.5"
  gem "rake", "~> 13.0"
  gem "chefstyle", "0.12.0"
  gem "concurrent-ruby", "~> 1.0"
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
end
