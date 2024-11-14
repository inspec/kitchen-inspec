# encoding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kitchen/verifier/inspec_version"

Gem::Specification.new do |spec|
  spec.name          = "kitchen-inspec"
  spec.version       = Kitchen::Verifier::INSPEC_VERSION
  spec.license       = "Apache-2.0"
  spec.authors       = ["Chef Software, Inc."]
  spec.email         = ["info@chef.io"]

  spec.summary       = "A Test Kitchen Verifier for InSpec"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/inspec/kitchen-inspec"

  spec.files         = `git ls-files -z`.split("\x0").grep(/LICENSE|Gemfile|kitchen-inspec.gemspec|^lib/)
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.3.0"
  spec.add_dependency "inspec", "~> 6.0" # for RC1 release 6.0 and the above has the licensing changes.
  spec.add_dependency "hashie", ">= 3.4", "<= 5.0"
end
