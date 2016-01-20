# -*- encoding: utf-8 -*-
source 'https://rubygems.org'
gemspec

group :guard do
  gem 'guard-rspec',    :require => nil
  gem 'guard-rubocop',  :require => nil
end

group :test do
  gem 'bundler', '~> 1.5'
  gem 'minitest', '~> 5.5'
  gem 'rake', '~> 10'
  gem 'rubocop', '~> 0.32'
  gem 'concurrent-ruby', '~> 0.9'
  gem 'codeclimate-test-reporter', :require => nil
  gem 'test-kitchen', '~> 1.4', :require => nil
end

group :integration do
  gem 'berkshelf'
  gem 'kitchen-dokken'
end

group :tools do
  gem 'pry', '~> 0.10'
  gem 'github_changelog_generator', '~> 1'
end
