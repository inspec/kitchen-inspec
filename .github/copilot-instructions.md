# Kitchen-InSpec Copilot Instructions

## Project Overview

Kitchen-InSpec is a Test Kitchen verifier plugin for Chef InSpec. It integrates InSpec compliance testing into the Test Kitchen testing workflow, allowing users to verify infrastructure configurations and compliance requirements as part of their CI/CD pipeline.

### Project Type
- **Type**: Ruby gem plugin for Test Kitchen
- **Purpose**: Verifier plugin that enables InSpec profile execution in Test Kitchen
- **License**: Apache 2.0
- **Maintainer**: Chef Software, Inc.

### Key Components
- **Core Class**: `Kitchen::Verifier::Inspec` - Main verifier implementation
- **Version Module**: `Kitchen::Verifier::INSPEC_VERSION` - Version constant
- **Dependencies**: InSpec (>= 2.2.64, < 8.0), Test Kitchen (>= 2.7, < 5), Hashie (>= 3.4, < 6.0)

## Architecture and Design Patterns

### Plugin Architecture
- Extends `Kitchen::Verifier::Base` from Test Kitchen
- Uses Kitchen's plugin system (API version 1)
- Implements InSpec's plugin v2 architecture
- Supports multiple transport backends (SSH, WinRM, Docker, Local)

### Key Design Patterns
1. **Strategy Pattern**: Different runner options based on transport type
2. **Template Method**: `call(state)` method orchestrates verification workflow
3. **Configuration Object**: Uses InSpec::Config for runtime configuration
4. **Plugin Loading**: Dynamic plugin discovery and loading via InSpec::Plugin::V2

### Threading Model
- **NOT thread-safe**: InSpec is based on RSpec which is not thread-safe
- Uses `no_parallel_for :verify` to disable parallel execution in Test Kitchen

## Code Organization

### Directory Structure
```
lib/
  kitchen/
    verifier/
      inspec.rb           # Main verifier implementation
      inspec_version.rb   # Version constant
spec/
  kitchen/
    verifier/
      inspec_spec.rb      # RSpec tests for verifier
  spec_helper.rb
test/
  integration/            # Integration test profiles
  recipes/                # Recipe-based test support
```

### File Responsibilities
- **inspec.rb**: 
  - Main verifier class (400+ lines)
  - Configuration management
  - Runner options generation for different transports
  - Test collection and execution
  - Plugin configuration
  
- **inspec_version.rb**: Version string management

## Coding Conventions

### Ruby Style
- **Ruby Version**: >= 2.3.0 (Currently targets Ruby 3.4)
- **Style Guide**: Cookstyle/Chefstyle for linting
- **Line Length**: Follow RuboCop defaults
- **Indentation**: 2 spaces
- **Test Framework**: RSpec for unit tests

### Naming Conventions
- **Classes**: CamelCase (e.g., `Kitchen::Verifier::Inspec`)
- **Methods**: snake_case (e.g., `runner_options`, `collect_tests`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `INSPEC_VERSION`)
- **Private Methods**: Marked with `private` keyword
- **Config Keys**: Symbol keys with underscores (e.g., `:test_base_path`, `:inspec_tests`)

### Method Naming Patterns
- `setup_*`: Configuration setup methods (e.g., `setup_inputs`, `setup_waivers`)
- `runner_options_for_*`: Transport-specific configuration (e.g., `runner_options_for_ssh`)
- `*_suite_files`: File discovery methods (e.g., `local_suite_files`)

## Configuration System

### Default Configuration
```ruby
default_config :inspec_tests, []
default_config :load_plugins, true
default_config :plugin_config, {}
default_config :backend_cache, true
```

### Configuration Keys
- **Test Selection**:
  - `inspec_tests`: Array of test profiles (paths, URLs, git repos, Supermarket)
  - `controls`: Array of specific controls to run
  - `test_base_path`: Base directory for tests (default: `test/integration`)
  - `suite_name`: Current test suite name

- **InSpec Runtime**:
  - `inputs` / `attributes`: Hash of input values for profiles
  - `input_files` / `attrs`: Array of input file paths
  - `waiver_files`: Array of waiver file paths
  - `load_plugins`: Enable/disable plugin loading (default: true)
  - `plugin_config`: Hash of plugin-specific configurations
  - `cache_inputs`: Enable/disable input caching (default: true)
  - `backend_cache`: Enable/disable backend caching (default: true)

- **Output Configuration**:
  - `reporter`: Array of reporter configurations with template support
  - `format`: Output format
  - `output`: Output file path with template support
  - `color`: Enable color output (default: true)
  - `profiles_path`: Custom profiles directory

- **Transport Configuration**:
  - `host`: Override target host
  - `port`: Override target port
  - `sudo`: Enable sudo (SSH only)
  - `sudo_command`: Custom sudo command
  - `sudo_options`: Sudo options
  - `proxy_command`: SSH proxy command
  - `forward_agent`: Enable SSH agent forwarding

- **Chef Licensing** (InSpec 6+):
  - `chef_license_key`: Chef license key
  - `chef_license_server`: Licensing service URL(s)

### Template Placeholders
Reporter and output paths support placeholders:
- `%{platform}`: Platform name
- `%{suite}`: Suite name

Example: `junit:path/to/results/%{platform}_%{suite}_inspec.xml`

## Test Discovery

### Default Test Locations
1. `test/integration/<suite_name>/` - Primary location
2. `test/integration/<suite_name>/inspec/` - If other frameworks detected
3. `test/recipes/` - Alternative location for cookbook testing

### Legacy Framework Detection
Detects and adapts to these frameworks in the same suite:
- inspec, serverspec, bats, pester, rspec, cucumber, minitest, bash

### Profile Sources
- **Local Path**: `{ path: '/path/to/profile' }`
- **Git Repository**: `{ git: 'https://github.com/org/repo.git', branch: 'main' }`
- **URL**: `{ url: 'https://example.com/profile.zip' }`
- **Supermarket**: `{ name: 'hardening/ssh-hardening' }`
- **Compliance**: `{ name: 'ssh', compliance: 'base/ssh' }`

## Transport Backends

### Supported Transports
1. **SSH** - Standard SSH transport
2. **WinRM** - Windows Remote Management
3. **Docker/Dokken** - Container-based testing
4. **DockerCLI** - Docker CLI transport
5. **Exec** - Local execution

### Transport-Specific Configuration
Each transport has a `runner_options_for_<transport>` method that:
- Maps Kitchen transport config to InSpec backend config
- Handles authentication (keys, passwords)
- Configures connection parameters (timeouts, retries)
- Sets backend-specific options

## Error Handling

### Exit Codes
- **0**: Success
- **101**: Success with skipped controls (treated as success)
- **Other**: Failure - raises `Kitchen::ActionFailed`

### Common Issues
1. **Thread Safety**: Never run verify in parallel
2. **Plugin Loading**: Must load plugins before config validation
3. **Input Caching**: May cause issues across suites if not disabled
4. **Version Compatibility**: Check InSpec version for feature support

## Testing Strategy

### Unit Tests (RSpec)
- **Location**: `spec/kitchen/verifier/inspec_spec.rb`
- **Framework**: RSpec with instance doubles
- **Coverage**: SimpleCov when COVERAGE env var is set
- **Approach**: 
  - Mock Kitchen instance, transport, platform, suite
  - Test configuration parsing
  - Test runner options generation
  - Test profile collection logic

### Integration Tests
- **Location**: `test/integration/` and `test/recipes/`
- **Approach**: Real Kitchen runs with InSpec profiles
- **Tools**: Berkshelf, kitchen-dokken for testing

### Quality Tasks
```bash
rake spec          # Run unit tests
rake lint          # Run Cookstyle/RuboCop
rake stats         # Display LOC stats
rake quality       # Run all quality checks
rake test          # Run all tests
```

## Version Compatibility

### InSpec Version Features
- **2.2.64+**: Plugin v2 support
- **3.10+**: `input_file` key (replaces `attrs`)
- **4.10+**: `inputs` key (replaces `attributes`)
- **4.26.2+**: `merge_plugin_config` method
- **5.x**: Current stable version
- **6.x-7.x**: Chef licensing support

### Test Kitchen Version
- **2.7+**: Minimum supported version
- **3.0+**: Supported since v2.5.0
- **4.x**: Current support
- **5.x**: Upper bound (not inclusive)

## Common Patterns

### Adding New Configuration
1. Add `default_config` declaration in class
2. Document in README.md
3. Add to `runner_options` or specific setup method
4. Add specs for new configuration
5. Update CHANGELOG.md

### Supporting New Transport
1. Add `runner_options_for_<transport>` method
2. Map transport config to InSpec backend options
3. Handle transport-specific authentication
4. Add specs with mocked transport
5. Update README with transport details

### Handling Version-Specific Features
```ruby
inspec_version = Gem::Version.new(::Inspec::VERSION)
if inspec_version >= Gem::Version.new("4.10")
  # Use new feature
else
  # Use legacy approach
end
```

## Deprecation Handling

### Current Deprecations
- `attrs` → Use `input_files` instead
- `attributes` → Use `inputs` instead

### Deprecation Pattern
```ruby
if config[:old_key]
  logger.warn("kitchen-inspec: please use 'new_key' instead of 'old_key'")
  config[:new_key] = config[:old_key]
end
```

## Logging

### Logger Usage
- Available as `logger` instance method (from Kitchen::Verifier::Base)
- Levels: debug, info, warn, error
- InSpec logging: `::Inspec::Log.level = Kitchen::Util.from_logger_level(logger.level)`

### Common Log Messages
```ruby
logger.debug("Initialize InSpec")
logger.debug "Options #{opts.inspect}"
logger.info("Loaded #{profile.name}")
logger.warn("kitchen-inspec: please use 'inputs' instead of 'attributes'")
```

## Dependencies and Bundler Groups

### Runtime Dependencies
- `inspec`: Core testing framework
- `hashie`: Hash extensions for configuration
- `test-kitchen`: Test orchestration framework

### Development Dependencies
- **test**: minitest, rake, cookstyle, rspec, simplecov, concurrent-ruby
- **integration**: berkshelf, kitchen-dokken
- **guard**: guard-rspec, guard-rubocop
- **tools**: pry

## Best Practices for Contributors

### Before Submitting Code
1. Run `rake test` to ensure all tests pass
2. Run `rake lint` to check code style
3. Update CHANGELOG.md with your changes
4. Update README.md if adding user-facing features
5. Add specs for new functionality
6. Ensure backward compatibility or document breaking changes

### Code Review Checklist
- [ ] Follows existing naming conventions
- [ ] Includes RSpec tests
- [ ] Updates documentation
- [ ] Maintains backward compatibility
- [ ] Handles InSpec version differences
- [ ] Proper error handling and logging
- [ ] No parallel execution issues

### Documentation Requirements
- Method-level comments for public APIs
- Inline comments for complex logic
- README updates for user-facing changes
- CHANGELOG entries for all changes

## Common Implementation Tasks

### Adding a New Input Source
1. Add configuration key with `default_config`
2. Implement setup method (e.g., `setup_my_input`)
3. Call setup method in `call(state)` before runner initialization
4. Add version check if feature is version-specific
5. Document in README with examples

### Extending Reporter Options
1. Parse config[:reporter] array
2. Apply template substitution with platform/suite
3. Pass to InSpec runner options
4. Add specs for template expansion
5. Document template variables

### Supporting New Profile Sources
1. Update `resolve_config_inspec_tests` to handle new source
2. Add validation logic
3. Ensure deduplication works correctly
4. Add specs with mocked InSpec runner
5. Document in README with yaml examples

## Debugging Tips

### Enable Detailed Logging
```yaml
verifier:
  name: inspec
  log_level: debug
```

### Common Debug Scenarios
1. **Profile not found**: Check test_base_path and suite_name
2. **Connection failures**: Verify runner_options for transport
3. **Input not applied**: Check input caching and version compatibility
4. **Plugin issues**: Verify load_plugins is true and InSpec version

### Useful Debug Commands
```ruby
# In code
logger.debug "Options #{opts.inspect}"
logger.debug "Tests collected: #{tests.inspect}"

# In specs
allow(logger).to receive(:debug)
expect(logger).to have_received(:debug).with(/pattern/)
```

## Performance Considerations

### Backend Caching
- Default: Enabled (`backend_cache: true`)
- Caches file reads and command execution results
- Disable if dealing with dynamic infrastructure

### Input Caching
- Default: Enabled for InSpec 4+
- Caches input values across suites
- Disable with `cache_inputs: false` if inputs vary per suite

### Plugin Loading
- Default: Enabled (`load_plugins: true`)
- Adds startup overhead
- Disable if not using custom reporters or input plugins

## API and Extension Points

### Kitchen Verifier API
- **api_version**: 1
- **call(state)**: Main entry point for verification
- **finalize_config!(instance)**: Configuration finalization hook
- **load_needed_dependencies!**: Lazy dependency loading

### InSpec Integration Points
- **InSpec::Config**: Configuration object
- **InSpec::Runner**: Test execution engine
- **InSpec::Plugin::V2**: Plugin system
- **InSpec::InputRegistry**: Input management

## Future Considerations

### Potential Enhancements
- Support for InSpec 8.x (update gemspec when released)
- Enhanced waiver file management
- Better multi-transport orchestration
- Improved input interpolation
- Streaming output for long-running tests

### Known Limitations
- Not thread-safe (inherent RSpec limitation)
- Input caching may cause cross-suite issues
- Template variables limited to platform/suite

## Quick Reference

### File Structure
- Core code: `lib/kitchen/verifier/inspec.rb`
- Version: `lib/kitchen/verifier/inspec_version.rb`
- Tests: `spec/kitchen/verifier/inspec_spec.rb`
- Integration: `test/integration/` or `test/recipes/`

### Key Methods
- `call(state)`: Main verification workflow
- `runner_options(transport, state, platform, suite)`: Generate InSpec config
- `collect_tests()`: Gather all test profiles
- `setup_inputs(opts, config)`: Configure inputs/attributes
- `setup_waivers(opts, config)`: Configure waiver files

### Configuration Flow
1. User defines config in `.kitchen.yml`
2. `finalize_config!` processes special paths (e.g., test/recipes)
3. `call(state)` generates runner options
4. Setup methods add inputs, waivers, licensing
5. InSpec::Config validates configuration
6. Plugin config merged (if InSpec 4.26.2+)
7. InSpec::Runner executes tests

This document should be used as a reference when working on kitchen-inspec code, writing tests, or reviewing pull requests.
