# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kitchen/verifier/inspec_version"
require "English"

Gem::Specification.new do |spec|
  spec.name          = "kitchen-inspec"
  spec.version       = Kitchen::Verifier::INSPEC_VERSION
  spec.license       = "Apache 2.0"
  spec.authors       = ["Fletcher Nichol"]
  spec.email         = ["fnichol@chef.io"]

  spec.summary       = "A Test Kitchen Verifier for Vulcano"
  spec.description   = spec.summary
  spec.homepage      = "http://github.com/chef/kitchen-inspec"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").
    reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "test-kitchen", "~> 1.4"
  spec.add_dependency "vulcano"

  spec.add_development_dependency "countloc", "~> 0.4"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov", "~> 0.10"

  # style and complexity libraries are tightly version pinned as newer releases
  # may introduce new and undesireable style choices which would be immediately
  # enforced in CI
  spec.add_development_dependency "finstyle",  "1.5.0"
  spec.add_development_dependency "cane",      "2.6.2"
end
