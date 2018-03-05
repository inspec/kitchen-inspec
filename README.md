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

You can also specify the host and port to be used by InSpec when targeting the node. Otherwise, it defaults to the hostname and port used by kitchen for converging.

```yaml
verifier:
  name: inspec
  host: 192.168.56.40
  port: 22
```

If you want to customize the output file per platform or test suite
you can use template format for your output variable. Current flags
supported:
 * _%{platform}_
 * _%{suite}_

```yaml
verifier:
  name: inspec
  format: junit
  output: path/to/results/%{platform}_%{suite}_inspec.xml
```

You can also decide to only run specific controls, instead of a full profile. This is done by specifying a list of controls:

```
suites:
  - name: supermarket
    run_list:
      - recipe[apt]
      - recipe[ssh-hardening]
    verifier:
      inspec_tests:
        - name: dev-sec/ssh-baseline
      controls:
        - sshd-46
    ...
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

In case you want to reuse tests across multiple cookbooks, they should become an extra artifact independent of a Chef cookbook, called [InSpec profiles](https://github.com/chef/inspec/blob/master/docs/profiles.md). Those can be easiliy added to existing local tests as demonstrated in previous sections. To include remote profiles, adapt the `verifier` attributes in `.kitchen.yml`

```yaml
suites:
  - name: default
    verifier:
      inspec_tests:
        - name: ssh-hardening
          url: https://github.com/dev-sec/tests-ssh-hardening
```

`inspec_tests` accepts all values that `inspec exec profile` would expect. We support:

- local directory eg. `path: /path/to/profile`
- github url `git: https://github.com/dev-sec/tests-ssh-hardening.git`
- Chef Supermarket `name: hardening/ssh-hardening` # defaults to supermarket (list all available profiles with `inspec supermarket profiles`)
- Chef Compliance `name: ssh` `compliance: base/ssh`

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
        - path: path/to/some/local/tests
        - name: ssh-hardening
          url: https://github.com/dev-sec/tests-ssh-hardening/archive/master.zip
        - name: os-hardening
          git: https://github.com/dev-sec/tests-os-hardening.git
  - name: supermarket
    run_list:
      - recipe[apt]
      - recipe[yum]
      - recipe[ssh-hardening]
    verifier:
      inspec_tests:
        - name: hardening/ssh-hardening  # name only defaults to supermarket
        - name: ssh-supermarket  # alternatively, you can explicitly specify that the profile is from supermarket in this way
          supermarket: hardening/ssh-hardening
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
        - name: ssh
          compliance: base/ssh
```

### Use attributes with your inspec profiles

To run a profile with attributes defined inline, you can adapt your `.kitchen.yml`:

```yaml
    verifier:
      inspec_tests:
        - path: test/integration/attributes
      attributes:
        user: bob
        password: secret
```

You can also define your attributes in an external file. Adapt your `.kitchen.yml` to point to that file:

```yaml
    verifier:
      inspec_tests:
        - path: test/integration/attributes
      attrs:
        - test/integration/profile-attribute.yml
  ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/chef/kitchen-inspec>.

## License

Apache 2.0 (see [LICENSE])

[license]: https://github.com/chef/kitchen-inspec/blob/master/LICENSE
