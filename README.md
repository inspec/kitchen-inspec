# Kitchen::InSpec - A Test Kitchen Verifier for InSpec

This is the kitchen driver for [InSpec](https://github.com/chef/inspec). Please find an [example here](https://github.com/chef/inspec/tree/master/examples/kitchen-chef).

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chef/kitchen-inspec.

## License

Apache 2.0 (see [LICENSE][license])

[license]: https://github.com/chef/kitchen-inspec/blob/master/LICENSE
