# Kitchen::InSpec - A Test Kitchen Verifier for InSpec

This is the kitchen driver for [InSpec](https://github.com/chef/inspec). To see the project in action, we have the following test-kitchen examples available:

 - [Chef and InSpec](https://github.com/chef/inspec/tree/master/examples/kitchen-chef)
 - [Puppet and InSpec](https://github.com/chef/inspec/tree/master/examples/kitchen-puppet)
 - [Ansible and InSpec](https://github.com/chef/inspec/tree/master/examples/kitchen-ansible)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kitchen-inspec'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kitchen-inspec

## Usage

In your .kitchen.yml include
```
verifier:
  name: inspec
```

Optionally, specify sudo and sudo_command if needed
```
verifier:
  name: inspec
  sudo: true
  sudo_command: 'supersizeme'
```

### Directory Structure

By default `kitchen-inspec` expects test to be in `test/integration/%suite%` directory structure (we use Chef as provisioner here):

```
.
├── Berksfile
├── Gemfile
├── README.md
├── metadata.rb
├── recipes
│   ├── default.rb
│   └── nginx.rb
└── test
    └── integration
        └── default
            └── web_spec.rb
```

### Directory Structure with complete profile

A complete profile is used here, including a custom inspec resource named `gordon_config`:

```
.
├── Berksfile
├── Gemfile
├── README.md
├── metadata.rb
├── recipes
│   ├── default.rb
│   └── nginx.rb
└── test
    └── integration
        └── default
            ├── controls
            │   └── gordon.rb
            ├── inspec.yml
            └── libraries
                └── gordon_config.rb
```

### Combination with other testing frameworks

If you need support with other testing frameworks, we recommend to place the tests in `test/integration/%suite%/inspec`:

```
.
├── Berksfile
├── Gemfile
├── README.md
├── metadata.rb
├── recipes
│   ├── default.rb
│   └── nginx.rb
└── test
    └── integration
        └── default
            └── inspec
                └── web_spec.rb
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chef/kitchen-inspec.

## License

Apache 2.0 (see [LICENSE][license])

[license]: https://github.com/chef/kitchen-inspec/blob/master/LICENSE
