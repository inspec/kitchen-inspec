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

        # gather connection options
        opts = runner_options(instance.transport, state, instance.platform.name, instance.suite.name)
        logger.debug "Options #{opts.inspect}"

        # add attributes
        opts[:attrs] = config[:attrs]
        opts[:attributes] = Hashie.stringify_keys config[:attributes] unless config[:attributes].nil?

        # setup logger
        ::Inspec::Log.init(STDERR)
        ::Inspec::Log.level = Kitchen::Util.from_logger_level(logger.level)

        # initialize runner
        runner = ::Inspec::Runner.new(opts)

        # add each profile to runner
        tests = collect_tests
        profile_ctx = nil
        tests.each do |target|
          profile_ctx = runner.add_target(target, opts)
        end

        profile_ctx ||= []
        profile_ctx.each do |profile|
          logger.info("Loaded #{profile.name} ")
        end

        exit_code = runner.run
        # 101 is a success as well (exit with no fails but has skipped controls)
        return if exit_code == 0 || exit_code == 101
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

        # only return the directory if it exists
        Pathname.new(base).exist? ? [{ :path => base }] : []
      end

      # Takes config[:inspec_tests] and modifies any value with a key of :path by adding the full path
      # @return [Array] array of modified hashes
      # @api private
      def resolve_config_inspec_tests
        config[:inspec_tests].map do |test_item|
          if test_item.is_a?(Hash)
            # replace the "path" key with an absolute path
            test_item[:path] = File.expand_path(test_item[:path]) if test_item.key?(:path)

            # delete any unnecessary keys to ensure deduplication in #collect_tests isn't
            # foiled by extra stuff. However, if the only entry is a "name" key, then
            # leave it alone so it can default to resolving to the Supermarket.
            unless test_item.keys == [:name]
              type_keys = [:path, :url, :git, :compliance, :supermarket]
              git_keys = [:branch, :tag, :ref]
              supermarket_keys = [:supermarket_url]
              test_item.delete_if { |k, v| !(type_keys + git_keys + supermarket_keys).include?(k) }
            end
          elsif File.exist?(test_item)
            # if the entry is a path to something on disk, rewrite as a Hash entry with a path key.
            # This is necessary to ensure that auto-detected local suite files found with
            # #local_suite_files are de-duplicated with relative path entries supplied by the user
            # in the inspec_tests array.
            #
            # If the path doesn't exist, it could be a URL, or it could simply be an error.
            # We will let it fall through and let InSpec raise the appropriate exception.
            test_item = { path: File.expand_path(test_item) }
          end

          test_item unless test_item.nil? || test_item.empty?
        end
      end

      # Returns an array of test profiles
      # @return [Array<String>] array of suite directories or remote urls
      # @api private
      def collect_tests
        # get local tests and get run list of profiles
        (local_suite_files + resolve_config_inspec_tests).compact.uniq
      end

      # Returns a configuration Hash that can be passed to a `Inspec::Runner`.
      #
      # @return [Hash] a configuration hash of string-based keys
      # @api private
      def runner_options(transport, state = {}, platform = nil, suite = nil) # rubocop:disable Metrics/AbcSize
        transport_data = transport.diagnose.merge(state)
        if respond_to?("runner_options_for_#{transport.name.downcase}", true)
          send("runner_options_for_#{transport.name.downcase}", transport_data)
        else
          raise Kitchen::UserError, "Verifier #{name} does not support the #{transport.name} Transport"
        end.tap do |runner_options|
          # default color to true to match InSpec behavior
          runner_options["color"] = (config[:color].nil? ? true : config[:color])
          runner_options["format"] = config[:format] unless config[:format].nil?
          runner_options["output"] = config[:output] % { platform: platform, suite: suite } unless config[:output].nil?
          runner_options["profiles_path"] = config[:profiles_path] unless config[:profiles_path].nil?
          runner_options["reporter"] = config[:reporter] unless config[:reporter].nil?
          runner_options[:controls] = config[:controls]

          # check to make sure we have a valid version for caching
          if config[:backend_cache]
            backend_cache_msg = "backend_cache requires InSpec version >= 1.47.0"
            logger.warn backend_cache_msg if Gem::Version.new(::Inspec::VERSION) < Gem::Version.new("1.47.0")
            runner_options[:backend_cache] = config[:backend_cache]
          else
            # default to false until we default to true in inspec
            runner_options[:backend_cache] = false
          end
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
          "sudo_options" => config[:sudo_options],
          "host" => config[:host] || kitchen[:hostname],
          "port" => config[:port] || kitchen[:port],
          "user" => kitchen[:username],
          "keepalive" => kitchen[:keepalive],
          "keepalive_interval" => kitchen[:keepalive_interval],
          "connection_timeout" => kitchen[:timeout],
          "connection_retries" => kitchen[:connection_retries],
          "connection_retry_sleep" => kitchen[:connection_retry_sleep],
          "max_wait_until_ready" => kitchen[:max_wait_until_ready],
          "compression" => kitchen[:compression],
          "compression_level" => kitchen[:compression_level],
          "proxy_command" => config[:proxy_command],
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
          "ssl" => URI(kitchen[:endpoint]).scheme == "https",
          "self_signed" => kitchen[:no_ssl_peer_verification],
          "host" => config[:host] || URI(kitchen[:endpoint]).hostname,
          "port" => config[:port] || URI(kitchen[:endpoint]).port,
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
      def runner_options_for_dokken(config_data)
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

      # Returns a configuration Hash that can be passed to a `Inspec::Runner`.
      #
      # @return [Hash] a configuration hash of string-based keys
      # @api private
      def runner_options_for_exec(config_data)
        opts = {
          "backend" => "local",
          "logger" => logger,
        }
        opts
      end
    end
  end
end
