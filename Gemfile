source "https://rubygems.org"
gemspec

group :guard do
  gem "guard-rspec",    require: nil
  gem "guard-rubocop",  require: nil
end

group :test do
  gem "minitest", ">= 5.5", "< 7.0"
  gem "rake", ">= 13.0", "< 14.0"
  gem "cookstyle", ">= 8.0", "< 9.0"
  gem "concurrent-ruby", ">= 1.0", "< 2.0"
  gem "rspec"
  gem "simplecov", ">= 0.12", "< 1.0"
  gem "countloc", ">= 0.4", "< 1.0"
end

group :integration do
  gem "chef-cli"
  # gem "inspec-core", ">= 5.0", "< 6.6.0" # Inspec 6.6.0+ requires license key to run, this limits it to pre license key for CI and testing purposes

  gem "kitchen-dokken"
end

group :tools do
  gem "pry", ">= 0.10", "< 1.0"
end
