# -*- encoding: utf-8 -*-
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

require "kitchen/verifier/inspec_version"
require "kitchen/verifier/base"

module Kitchen

  module Verifier

    # InSpec verifier for Kitchen.
    #
    # @author Fletcher Nichol <fnichol@chef.io>
    class Inspec < Kitchen::Verifier::Base

      kitchen_verifier_api_version 1

      plugin_version Kitchen::Verifier::INSPEC_VERSION

      # (see Base#call)
      def call(state)
        transport_data = instance.transport.diagnose.merge(state)

        runner_options = case (name = instance.transport.name.downcase)
                         when "ssh"
                           runner_options_for_ssh(transport_data)
                         else
                           raise Kitchen::UserError, "Verifier #{name}",
                             " does not support the #{name} Transport"
                         end
        tests = local_suite_files

        runner = ::Inspec::Runner.new(runner_options)
        runner.add_tests(tests)
        debug("Running specs from: #{tests.inspect}")
        runner.run
      end

      private

      # Determines whether or not a local workstation file exists under a
      # Chef-related directory.
      #
      # @return [truthy,falsey] whether or not a given file is some kind of
      #   Chef-related file
      # @api private
      def chef_data_dir?(base, file)
        file =~ %r{^#{base}/(data|data_bags|environments|nodes|roles)/}
      end

      # (see Base#load_needed_dependencies!)
      def load_needed_dependencies!
        require "inspec"
      end

      # Returns an Array of test suite filenames for the related suite currently
      # residing on the local workstation. Any special provisioner-specific
      # directories (such as a Chef roles/ directory) are excluded.
      #
      # @return [Array<String>] array of suite files
      # @api private
      def local_suite_files
        base = File.join(config[:test_base_path], config[:suite_name])
        glob = File.join(base, "**/*_spec.rb")
        Dir.glob(glob).reject do |f|
          chef_data_dir?(base, f) || File.directory?(f)
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
          "compression_level" => kitchen[:compression_level]
        }
        opts["key_files"] = kitchen[:keys] unless kitchen[:keys].nil?
        opts["password"] = kitchen[:password] unless kitchen[:password].nil?

        opts
      end
    end
  end
end
