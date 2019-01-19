# -*- encoding: utf-8 -*-
source "https://rubygems.org"
gemspec

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
  gem "concurrent-ruby", "~> 1.0"
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
end
