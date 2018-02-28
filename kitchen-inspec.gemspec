# encoding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kitchen/verifier/inspec_version"
require "English"

Gem::Specification.new do |spec|
  spec.name          = "kitchen-inspec"
  spec.version       = Kitchen::Verifier::INSPEC_VERSION
  spec.license       = "Apache-2.0"
  spec.authors       = ["Fletcher Nichol"]
  spec.email         = ["fnichol@chef.io"]

  spec.summary       = "A Test Kitchen Verifier for InSpec"
  spec.description   = spec.summary
  spec.homepage      = "http://github.com/chef/kitchen-inspec"

  spec.files         = `git ls-files -z`.split("\x0")
    .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.1.0"
  spec.add_dependency "inspec", ">=0.34.0", "<3.0.0"
  spec.add_dependency "test-kitchen", "~> 1.6"
  spec.add_dependency "hashie", "~> 3.4"
end
