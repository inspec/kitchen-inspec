# Kitchen::InSpec - A Test Kitchen Verifier for InSpec

[![Build Status Master](https://travis-ci.org/chef/kitchen-inspec.svg?branch=master)](https://travis-ci.org/chef/kitchen-inspec) [![Gem Version](https://badge.fury.io/rb/kitchen-inspec.svg)](https://badge.fury.io/rb/kitchen-inspec)

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

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install kitchen-inspec
```

## Usage

In your .kitchen.yml include

```yaml
verifier:
  name: inspec
```

Optionally specify sudo and sudo_command

```yaml
verifier:
  name: inspec
  sudo: true
  sudo_command: 'skittles'
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
│   ├── default.rb
│   └── nginx.rb
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
│   ├── default.rb
│   └── nginx.rb
└── test
    └── integration
        └── default
            ├── controls
            │   └── gordon.rb
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
│   ├── default.rb
│   └── nginx.rb
└── test
    └── integration
        └── default
            └── inspec
                └── web_spec.rb
```

### Use remote InSpec profiles

In case you want to reuse tests across multiple cookbooks, they should become an extra artifact independent of a Chef cookbook, call [InSpec profiles](https://github.com/chef/inspec/blob/master/docs/profiles.rst). Those can be easiliy added to existing local tests as demonstrated in previous sections. To include remote profiles, adapt the `verifier` attributes in `.kitchen.yml`

```yaml
suites:
  - name: default
    verifier:
      inspec_tests:
        - https://github.com/dev-sec/tests-ssh-hardening
```

`inspec_tests` accepts all values that `inspec exec profile` would expect. We support:

- local directory eg. `/path/to/profile`
- github url `https://github.com/dev-sec/tests-ssh-hardening`
- Chef Supermarket `supermarket://hardening/ssh-hardening` (list all available profiles with `inspec supermarket profiles`)
- Chef Compliance `compliance://base/ssh`

The following example illustrates the usage in a `.kitchen.yml`

```yaml
suites:
  - name: contains_inspec
    run_list:
      - recipe[apt]
      - recipe[yum]
      - recipe[ssh-hardening]
      - recipe[os-hardening]
    verifier:
      inspec_tests:
        - https://github.com/dev-sec/tests-ssh-hardening
        - https://github.com/dev-sec/tests-os-hardening
  - name: supermarket
    run_list:
      - recipe[apt]
      - recipe[yum]
      - recipe[ssh-hardening]
    verifier:
      inspec_tests:
        - supermarket://hardening/ssh-hardening
  # before you are able to use the compliance plugin, you need to run
  # insecure is only required if you use self-signed certificates
  # $ inspec compliance login https://compliance.test --user admin --insecure --token ''
  - name: compliance
    run_list:
      - recipe[apt]
      - recipe[yum]
      - recipe[ssh-hardening]
    verifier:
      inspec_tests:
        - compliance://base/ssh
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/chef/kitchen-inspec>.

## License

Apache 2.0 (see [LICENSE])

[license]: https://github.com/chef/kitchen-inspec/blob/master/LICENSE
