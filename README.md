# Kitchen::InSpec - A Test Kitchen Verifier for InSpec

- **Project State: Active**
- **Issues Response SLA: 3 business days**
- **Pull Request Response SLA: 3 business days**

For more information on project states and SLAs, see [this documentation](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md).

[![Build Status Master](https://travis-ci.org/inspec/kitchen-inspec.svg?branch=master)](https://travis-ci.org/inspec/kitchen-inspec) [![Gem Version](https://badge.fury.io/rb/kitchen-inspec.svg)](https://badge.fury.io/rb/kitchen-inspec)

This is the kitchen driver for [InSpec](https://github.com/chef/inspec). To see the project in action, we have the following test-kitchen examples available:

- [Chef and InSpec](https://github.com/inspec/inspec/tree/master/examples/kitchen-chef)
- [Puppet and InSpec](https://github.com/inspec/inspec/tree/master/examples/kitchen-puppet)
- [Ansible and InSpec](https://github.com/inspec/inspec/tree/master/examples/kitchen-ansible)

## Installation

`Note:` kitchen-inspec ships as part of ChefDK. Installation is not necessary for DK users.

Add this line to your application's Gemfile:

```ruby
gem 'kitchen-inspec'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install kitchen-inspec
```

## Usage

In your kitchen.yml include

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

### Expected Directory Structure

By default `kitchen-inspec` expects test to be in `test/integration/%suite%` directory structure (we use Chef as provisioner here):

```text
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

#### Directory Structure with complete profile

A complete profile is used here, including a custom InSpec resource named `gordon_config`:

```text
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

#### Combination with other testing frameworks

If you need support with other testing frameworks, we recommend to place the tests in `test/integration/%suite%/inspec`:

```text
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

### Specifying the Sudo Command

You can enable/disable sudo and set your own custom sudo command.

```yaml
verifier:
  name: inspec
  sudo: true
  sudo_command: 'skittles'
```

### Custom Host Settings

You can also specify the host, port, and proxy settings to be used by InSpec when targeting the node. Otherwise, it defaults to the hostname and port used by kitchen for converging.

```yaml
verifier:
  name: inspec
  host: 192.168.56.40
  port: 22
  proxy_command: ssh user@1.2.3.4 -W %h:%p
```

### Custom Outputs

If you want to customize the output file per platform or test suite you can use template format for your output variable. Current flags supported:

- _%{platform}_
- _%{suite}_

```yaml
verifier:
  name: inspec
  reporter:
    - cli
    - junit:path/to/results/%{platform}_%{suite}_inspec.xml
```

You can also decide to only run specific controls, instead of a full profile. This is done by specifying a list of controls:

```yaml
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

### Use remote InSpec profiles

In case you want to reuse tests across multiple cookbooks, they should become an extra artifact independent of a Chef cookbook, called [InSpec profiles](https://github.com/inspec/inspec/blob/master/docs/profiles.md). Those can be easily added to existing local tests as demonstrated in previous sections. To include remote profiles, adapt the `verifier` attributes in `kitchen.yml`

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

The following example illustrates the usage in a `kitchen.yml`

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
          supermarket_url: http://supermarket.example.com
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

### Use inputs with your InSpec profiles

To run a profile with inputs defined inline, you can adapt your `kitchen.yml`:

```yaml
    verifier:
      inspec_tests:
        - path: test/integration/attributes
      inputs:
        user: bob
        password: secret
```

You can also define your inputs in external files. Adapt your `kitchen.yml` to point to those files:

```yaml
    verifier:
      inspec_tests:
        - path: test/integration/attributes
      input_files:
        - test/integration/profile-attribute.yml
```

## Use waivers with your InSpec profiles

You can define your [waivers](https://docs.chef.io/inspec/waivers/) in external files:

```yaml
    verifier:
      inspec_tests:
        - path: test/integration/attributes
      input_files:
        - test/integration/profile-attribute.yml
      waiver_files:
        - test/integration/control-waiver-01.yml
```

### Use inspec plugins

By default, the verifier loads Inspec plugins such as additional Reporter or Input plugins. This adds a small delay as the system scans for plugins. If you know you are not using special Reporters or Inputs, you can disable plugin loading:

```yaml
    verifier:
      load_plugins: false
```

Some Inspec plugins allow further configuration. You can supply these settings as well with InSpec 4.26 or newer:

```yaml
    verifier:
      plugin_config:
        example_plugin_name:
          example_setting: "Example value"
```

When using Input plugins, please be aware that input values get cached between suites. If you want to re-evaluate these values for every suite, you can deactivate the cache:

```yaml
    verifier:
      cache_inputs: false
```

### Chef InSpec Backend Cache

 Chef InSpec uses a cache when executing commands and accessing files on the remote target. The cache is enabled by default. To disable the cache:

 ```yaml
     verifier:
       backend_cache: false
 ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/inspec/kitchen-inspec>.

## License

Apache 2.0 (see [LICENSE])

[license]: https://github.com/inspec/kitchen-inspec/blob/master/LICENSE
