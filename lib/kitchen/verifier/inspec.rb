# encoding: utf-8
#
# Author:: Fletcher Nichol (<fnichol@chef.io>)
# Author:: Christoph Hartmann (<chartmann@chef.io>)
#
# Copyright (C) 2015, Chef Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen/transport/ssh"
require "kitchen/transport/winrm"
require "kitchen/verifier/inspec_version"
require "kitchen/verifier/base"

require "uri"
require "pathname"

module Kitchen
  module Verifier
    # InSpec verifier for Kitchen.
    #
    # @author Fletcher Nichol <fnichol@chef.io>
    class Inspec < Kitchen::Verifier::Base # rubocop:disable Metrics/ClassLength
      kitchen_verifier_api_version 1
      plugin_version Kitchen::Verifier::INSPEC_VERSION

      default_config :inspec_tests, []

      # A lifecycle method that should be invoked when the object is about
      # ready to be used. A reference to an Instance is required as
      # configuration dependant data may be access through an Instance. This
      # also acts as a hook point where the object may wish to perform other
      # last minute checks, validations, or configuration expansions.
      #
      # @param instance [Instance] an associated instance
      # @return [self] itself, for use in chaining
      # @raise [ClientError] if instance parameter is nil
      def finalize_config!(instance)
        super

        # We want to switch kitchen-inspec to look for its tests in
        # `cookbook_dir/test/recipes` instead of `cookbook_dir/test/integration`
        # Unfortunately there is no way to read `test_base_path` from the
        # .kitchen.yml, it can only be provided on the CLI.
        # See https://github.com/test-kitchen/test-kitchen/issues/1077
        inspec_test_dir = File.join(config[:kitchen_root], "test", "recipes")
        if File.directory?(inspec_test_dir)
          config[:test_base_path] = inspec_test_dir
        end

        self
      end

      # (see Base#call)
      def call(state)
        logger.debug("Initialize InSpec")
        opts = runner_options(instance.transport, state)
        runner = ::Inspec::Runner.new(opts)

        # add each profile to runner
        tests = collect_tests
        tests.each { |target| runner.add_target(target, opts) }

        logger.debug("Running tests from: #{tests.inspect}")
        exit_code = runner.run
        return if exit_code == 0
        raise ActionFailed, "Inspec Runner returns #{exit_code}"
      end

      private

      # (see Base#load_needed_dependencies!)
      def load_needed_dependencies!
        require "inspec"
        # TODO: this should be easier. I would expect to load a single class here
        # load supermarket plugin, this is part of the inspec gem
        require "bundles/inspec-supermarket/api"
        require "bundles/inspec-supermarket/target"

        # load the compliance plugin
        require "bundles/inspec-compliance/configuration"
        require "bundles/inspec-compliance/support"
        require "bundles/inspec-compliance/http"
        require "bundles/inspec-compliance/api"
        require "bundles/inspec-compliance/target"
      end

      # Returns an Array of test suite filenames for the related suite currently
      # residing on the local workstation. Any special provisioner-specific
      # directories (such as a Chef roles/ directory) are excluded.
      #
      # we support the base directories
      # - test/integration
      # - test/integration/inspec (prefered if used with other test environments)
      #
      # we do not filter for specific directories, this is core of inspec
      #
      # @return [Array<String>] array of suite directories
      # @api private
      def local_suite_files
        base = File.join(config[:test_base_path], config[:suite_name])
        legacy_mode = false
        # check for testing frameworks, we may need to add more
        %w{inspec serverspec bats pester rspec cucumber minitest bash}.each do |fw|
          if Pathname.new(File.join(base, fw)).exist?
            logger.info("Detected alternative framework tests for `#{fw}`")
            legacy_mode = true
          end
        end

        base = File.join(base, "inspec") if legacy_mode
        logger.info("Use `#{base}` for testing")

        # only return the directory if it exists
        Pathname.new(base).exist? ? [base] : []
      end

      # Returns an array of test profiles
      # @return [Array<String>] array of suite directories or remote urls
      # @api private
      def collect_tests
        # get local tests and get run list of profiles
        (local_suite_files + config[:inspec_tests]).compact
      end

      # Returns a configuration Hash that can be passed to a `Inspec::Runner`.
      #
      # @return [Hash] a configuration hash of string-based keys
      # @api private
      def runner_options(transport, state = {}) # rubocop:disable Metrics/AbcSize
        transport_data = transport.diagnose.merge(state)
        if transport.is_a?(Kitchen::Transport::Ssh)
          runner_options_for_ssh(transport_data)
        elsif transport.is_a?(Kitchen::Transport::Winrm)
          runner_options_for_winrm(transport_data)
        # optional transport which is not in core test-kitchen
        elsif defined?(Kitchen::Transport::Dokken) && transport.is_a?(Kitchen::Transport::Dokken)
          runner_options_for_docker(transport_data)
        else
          raise Kitchen::UserError, "Verifier #{name} does not support the #{transport.name} Transport"
        end.tap do |runner_options|
          # default color to true to match InSpec behavior
          runner_options["color"] = (config[:color].nil? ? true : config[:color])
          runner_options["format"] = config[:format] unless config[:format].nil?
          runner_options["output"] = config[:output] unless config[:output].nil?
          runner_options["profiles_path"] = config[:profiles_path] unless config[:profiles_path].nil?
        end
      end

      # Returns a configuration Hash that can be passed to a `Inspec::Runner`.
      #
      # @return [Hash] a configuration hash of string-based keys
      # @api private
      def runner_options_for_ssh(config_data)
        kitchen = instance.transport.send(:connection_options, config_data).dup
        opts = {
          "backend" => "ssh",
          "logger" => logger,
          # pass-in sudo config from kitchen verifier
          "sudo" => config[:sudo],
          "sudo_command" => config[:sudo_command],
          "host" => kitchen[:hostname],
          "port" => kitchen[:port],
          "user" => kitchen[:username],
          "keepalive" => kitchen[:keepalive],
          "keepalive_interval" => kitchen[:keepalive_interval],
          "connection_timeout" => kitchen[:timeout],
          "connection_retries" => kitchen[:connection_retries],
          "connection_retry_sleep" => kitchen[:connection_retry_sleep],
          "max_wait_until_ready" => kitchen[:max_wait_until_ready],
          "compression" => kitchen[:compression],
          "compression_level" => kitchen[:compression_level],
          "keys_only" => true,
        }
        opts["key_files"] = kitchen[:keys] unless kitchen[:keys].nil?
        opts["password"] = kitchen[:password] unless kitchen[:password].nil?
        opts
      end

      # Returns a configuration Hash that can be passed to a `Inspec::Runner`.
      #
      # @return [Hash] a configuration hash of string-based keys
      # @api private
      def runner_options_for_winrm(config_data)
        kitchen = instance.transport.send(:connection_options, config_data).dup
        opts = {
          "backend" => "winrm",
          "logger" => logger,
          "host" => URI(kitchen[:endpoint]).hostname,
          "port" => URI(kitchen[:endpoint]).port,
          "user" => kitchen[:user],
          "password" => kitchen[:password] || kitchen[:pass],
          "connection_retries" => kitchen[:connection_retries],
          "connection_retry_sleep" => kitchen[:connection_retry_sleep],
          "max_wait_until_ready" => kitchen[:max_wait_until_ready],
        }
        opts
      end

      # Returns a configuration Hash that can be passed to a `Inspec::Runner`.
      #
      # @return [Hash] a configuration hash of string-based keys
      # @api private
      def runner_options_for_docker(config_data)
        kitchen = instance.transport.send(:connection_options, config_data).dup
        #
        # Note: kitchen-dokken uses two containers the
        #  - config_data[:data_container][:Id] : (hosts chef-client)
        #  - config_data[:runner_container][:Id] : (the kitchen-container)
        opts = {
          "backend" => "docker",
          "logger" => logger,
          "host" => config_data[:runner_container][:Id],
          "connection_timeout" => kitchen[:timeout],
          "connection_retries" => kitchen[:connection_retries],
          "connection_retry_sleep" => kitchen[:connection_retry_sleep],
          "max_wait_until_ready" => kitchen[:max_wait_until_ready],
        }
        logger.debug "Connect to Container: #{opts['host']}"
        opts
      end
    end
  end
end
