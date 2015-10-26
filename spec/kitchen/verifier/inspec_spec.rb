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

require_relative "../../spec_helper"

require "logger"

require "kitchen/verifier/inspec"
require "kitchen/transport/ssh"

describe Kitchen::Verifier::Inspec do

  let(:logged_output)     { StringIO.new }
  let(:logger)            { Logger.new(logged_output) }
  let(:config)            { Hash.new }
  let(:transport_config)  { Hash.new }

  let(:platform) do
    instance_double("Kitchen::Platform", :os_type => nil, :shell_type => nil)
  end

  let(:suite) do
    instance_double("Kitchen::Suite", :name => "germany")
  end

  let(:transport) do
    instance_double(
      "Kitchen::Transport::Dummy",
      :name => "wickedsauce",
      :diagnose => transport_config
    )
  end

  let(:instance) do
    instance_double(
      "Kitchen::Instance",
      :name => "coolbeans",
      :logger => logger,
      :platform => platform,
      :suite => suite,
      :transport => transport,
      :to_str => "instance"
    )
  end

  let(:test_files) do
    %w[base_spec.rb another_spec.rb supporting.rb other.json]
  end

  before do
    @root = Dir.mktmpdir
    config[:test_base_path] = @root
  end

  after do
    FileUtils.remove_entry(@root)
  end

  let(:verifier) do
    Kitchen::Verifier::Inspec.new(config).finalize_config!(instance)
  end

  it "verifier api_version is 1" do
    expect(verifier.diagnose_plugin[:api_version]).to eq(1)
  end

  it "plugin_version is set to Kitchen::Verifier::INSPEC_VERSION" do
    expect(verifier.diagnose_plugin[:version]).
      to eq(Kitchen::Verifier::INSPEC_VERSION)
  end

  describe "configuration" do
    # nothing yet, woah!
  end

  context "with an ssh transport" do

    let(:transport_config) do
      {
        :hostname => "boogie",
        :port => "I shouldn't be used",
        :username => "dance",
        :ssh_key => "/backstage/pass",
        :keepalive => "keepalive",
        :keepalive_interval => "forever",
        :connection_timeout => "nope",
        :connection_retries => "thousand",
        :connection_retry_sleep => "sleepy",
        :max_wait_until_ready => 42,
        :compression => "maxyo",
        :compression_level => "pico"
      }
    end

    let(:transport) do
      Kitchen::Transport::Ssh.new(transport_config)
    end

    let(:runner) do
      instance_double("Inspec::Runner")
    end

    before do
      allow(runner).to receive(:add_tests)
      allow(runner).to receive(:run)
    end

    it "constructs a Inspec::Runner using transport config data and state" do
      config[:sudo] = "jellybeans"

      expect(Inspec::Runner).to receive(:new).
        with(hash_including(
          "backend" => "ssh",
          "logger" => logger,
          "sudo" => "jellybeans",
          "host" => "boogie",
          "port" => 123,
          "user" => "dance",
          "keepalive" => "keepalive",
          "keepalive_interval" => "forever",
          "connection_timeout" => "nope",
          "connection_retries" => "thousand",
          "connection_retry_sleep" => "sleepy",
          "max_wait_until_ready" => 42,
          "compression" => "maxyo",
          "compression_level" => "pico",
          "key_files" => ["/backstage/pass"]
        )).
        and_return(runner)

      verifier.call(:port => 123)
    end

    it "adds *spec.rb test files to runner" do
      create_test_files
      allow(Inspec::Runner).to receive(:new).and_return(runner)
      expect(runner).to receive(:add_tests).with([
        File.join(config[:test_base_path], "germany", "another_spec.rb"),
        File.join(config[:test_base_path], "germany", "base_spec.rb")
      ])

      verifier.call(Hash.new)
    end

    it "calls #run on the runner" do
      allow(Inspec::Runner).to receive(:new).and_return(runner)
      expect(runner).to receive(:run)

      verifier.call(Hash.new)
    end
  end

  context "with an winrm transport" do
    # coming soon
  end

  context "with an unsupported transport" do

    it "#call raises a UserError" do
      expect { verifier.call(Hash.new) }.to raise_error(Kitchen::UserError)
    end
  end

  def create_test_files
    base = File.join(config[:test_base_path], "germany")

    test_files.map { |f| File.join(base, f) }.each do |file|
      FileUtils.mkdir_p(File.dirname(file))
      File.open(file, "wb") { |f| f.write("hello") }
    end
  end
end
